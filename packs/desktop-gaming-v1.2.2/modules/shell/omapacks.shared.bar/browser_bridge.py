#!/usr/bin/env python3
"""Local, stdin/stdout browser adapter. No server, clipboard or browsing log.

Read only the browser's chrome and active document URL, never page descendants.
Bind to PID + active accessible frame after compositor address verification.
"""
import json
import os
import re
import subprocess
import sys
import time
import warnings

import gi
gi.require_version('Atspi', '2.0')
from gi.repository import Atspi, Gio, GLib

warnings.filterwarnings('ignore', category=DeprecationWarning)
Atspi.set_timeout(500, 1000)
IDS = {'back-button', 'forward-button', 'reload-button', 'stop-button', 'urlbar-input',
       'PanelUI-menu-button', 'unified-extensions-button', 'downloads-button'}
SKIP = {Atspi.Role.MENU, Atspi.Role.MENU_BAR, Atspi.Role.PAGE_TAB_LIST}
DOCUMENTS = {Atspi.Role.DOCUMENT_WEB, Atspi.Role.DOCUMENT_FRAME}
BROWSERS = {'firefox', 'org.mozilla.firefox', 'zen'}
SHORTCUTS = {
    'back': ('ALT', 'Left'), 'forward': ('ALT', 'Right'), 'reload': ('CTRL', 'r'), 'stop': ('', 'Escape'),
    'native-address': ('CTRL', 'l'), 'new-tab': ('CTRL', 't'),
    'history': ('CTRL', 'h'), 'bookmarks': ('CTRL', 'b'),
    # These fallbacks preserve native functions when a button was removed
    # from the browser's customizable toolbar. Downloads is Firefox on Linux.
    'menu': ('', 'F10'), 'extensions': ('CTRL + SHIFT', 'a'),
    'downloads': ('CTRL + SHIFT', 'y'),
}
NATIVE_BUTTONS = {'menu': 'PanelUI-menu-button', 'extensions': 'unified-extensions-button',
                  'downloads': 'downloads-button'}


def address(value):
    """Only compositor addresses, never a title/URL or a caller's selector."""
    value = str(value or '').lower().removeprefix('0x')
    return value if re.fullmatch('[0-9a-f]{1,32}', value) else ''


def target_matches(context, active, pid=0):
    expected = address(context.get('windowAddress'))
    return bool(context.get('id') == 'browser' and expected
                and expected == address(active.get('address'))
                and str(context.get('appId', '')).lower() in BROWSERS
                and str(active.get('class', '')).lower() == str(context.get('appId', '')).lower()
                and isinstance(active.get('pid'), int) and active['pid'] > 0
                and (not pid or active['pid'] == pid)
                and (not context.get('pid') or context['pid'] == active['pid']))


def unexpired(message):
    deadline = message.get('expiresAtMs')
    return isinstance(deadline, (int, float)) and time.time() * 1000 <= deadline


def key_command(window_address, mods, key, state):
    """Static key allowlist and hex-only address make the Lua expression data-safe."""
    target = address(window_address)
    if not target or (mods, key) not in SHORTCUTS.values() or state not in ('down', 'up'):
        raise ValueError('Invalid directed shortcut')
    expression = ('hl.dsp.send_key_state({ mods = "%s", key = "%s", state = "%s", '
                  'window = "address:0x%s" })') % (mods, key, state, target)
    return ['hyprctl', 'dispatch', expression]


def dispatch_key(window_address, mods, key, state):
    result = subprocess.run(key_command(window_address, mods, key, state), capture_output=True,
                            text=True, check=True, timeout=1)
    # hyprctl can return an error string with an otherwise successful process.
    if result.stdout.strip().lower() != 'ok':
        raise RuntimeError('The compositor rejected the directed shortcut')


def directed_shortcut(window_address, mods, key):
    # Match Omarchy's installed key-state workaround: a single send_shortcut
    # may leave synthetic keys repeating. Always release the same destination,
    # even if it loses focus or down fails after reaching the compositor.
    try:
        dispatch_key(window_address, mods, key, 'down')
        time.sleep(0.05)
    finally:
        dispatch_key(window_address, mods, key, 'up')


def hypr(name):
    return json.loads(subprocess.check_output(['hyprctl', name, '-j'], text=True, timeout=1))


def enabled(a):
    return bool(a and a.get_state_set().contains(Atspi.StateType.ENABLED))


def loading(controls):
    # Firefox removes Stop with display:none when Reload is active. VISIBLE
    # tracks that functional visibility; SHOWING additionally requires the
    # control not to be scrolled/clipped offscreen by the sliding toolbox.
    stop = controls.get('stop-button')
    return bool(stop and stop.get_state_set().contains(Atspi.StateType.VISIBLE))


def scan(frame):
    controls, urls = {}, []
    todo = [(frame, 0)]
    for _ in range(500):
        if not todo:
            break
        a, depth = todo.pop()
        role = a.get_role()
        if role in DOCUMENTS:
            if a.get_state_set().contains(Atspi.StateType.SHOWING):
                value = Atspi.Document.get_document_attribute_value(a, 'DocURL')
                if value:
                    urls.append(value)
            continue
        if role in SKIP or depth > 12:
            continue
        key = a.get_attributes().get('id')
        if key in IDS:
            controls[key] = a
        todo.extend((a.get_child_at_index(i), depth + 1) for i in reversed(range(min(a.get_child_count(), 100))))
    return controls, urls


class Bridge:
    def __init__(self):
        self.context = {}
        self.target_pid = 0
        self.frame = None
        self.controls = {}
        self.pending = 0
        self.last = None
        self.buffer = b''
        self.listener = Atspi.EventListener.new(self.event)
        for event in ['window:activate', 'object:text-changed', 'object:state-changed:enabled',
                      'object:state-changed:busy', 'object:state-changed:showing', 'object:state-changed:active',
                      'object:state-changed:visible',
                      'object:selection-changed', 'document:load-complete']:
            self.listener.register(event)
        self.enable_accessibility()
        GLib.io_add_watch(sys.stdin.fileno(), GLib.IO_IN | GLib.IO_HUP, self.input)
        GLib.timeout_add(1500, self.poll)

    def enable_accessibility(self):
        # Firefox initializes accessibility once focused. It observes this
        # standard session property; no browser security preferences change.
        try:
            bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
            bus.call_sync('org.a11y.Bus', '/org/a11y/bus', 'org.freedesktop.DBus.Properties',
                          'Set', GLib.Variant('(ssv)', ('org.a11y.Status', 'IsEnabled',
                          GLib.Variant('b', True))), None, Gio.DBusCallFlags.NONE, 1000, None)
        except GLib.Error:
            pass

    def emit(self, state):
        state['revision'] = self.context.get('revision', -1)
        line = json.dumps(state, ensure_ascii=False)
        if line != self.last:
            print(line, flush=True)
            self.last = line

    def result(self, message, delivered, description='', method=''):
        # Results are never deduplicated, and retain the request's revision
        # even if a newer context arrived. "delivered" is not "page loaded".
        print(json.dumps({'type': 'action-result', 'requestId': message.get('requestId'),
                          'revision': message.get('revision'), 'action': message.get('action'),
                          'delivered': delivered, 'message': description, 'method': method},
                         ensure_ascii=False), flush=True)

    def input(self, fd, condition):
        if condition & GLib.IO_HUP:
            Atspi.event_quit()
            return False
        self.buffer += os.read(fd, 65536)
        while b'\n' in self.buffer:
            line, self.buffer = self.buffer.split(b'\n', 1)
            try:
                message = json.loads(line)
                if message.get('type') == 'focus':
                    ctx = message['context']
                    if ctx == self.context:
                        continue
                    self.context, self.frame, self.controls = ctx, None, {}
                    self.target_pid = 0
                    self.emit({'ready': False})
                    self.schedule()
                elif message.get('type') == 'action':
                    self.action(message)
            except (ValueError, KeyError, TypeError, GLib.Error, subprocess.SubprocessError):
                self.emit({'type': 'error', 'message': 'No se pudo comunicar con el navegador.'})
        return True

    def event(self, event, *_):
        if self.context.get('id') != 'browser':
            return
        try:
            if event.source.get_process_id() != self.target_pid:
                return
            # Most page events are irrelevant. Never traverse their contents.
            role = event.source.get_role()
            key = event.source.get_attributes().get('id')
            if key in IDS or role in DOCUMENTS or role in {Atspi.Role.FRAME, Atspi.Role.PAGE_TAB_LIST}:
                self.schedule()
        except GLib.Error:
            pass

    def schedule(self):
        if not self.pending:
            self.pending = GLib.timeout_add(100, self.refresh)

    def poll(self):
        if self.context.get('id') == 'browser':
            self.schedule()
        return True

    def bind(self):
        ctx = self.context
        active = hypr('activewindow')
        if not target_matches(ctx, active):
            return
        self.target_pid = active.get('pid', 0)
        desktop = Atspi.get_desktop(0)
        desktop.clear_cache()
        for i in range(desktop.get_child_count()):
            app = desktop.get_child_at_index(i)
            if app.get_process_id() != self.target_pid:
                continue
            app.clear_cache()
            candidates = []
            for j in range(app.get_child_count()):
                frame = app.get_child_at_index(j)
                frame.clear_cache()
                if frame.get_role() == Atspi.Role.FRAME and frame.get_state_set().contains(Atspi.StateType.ACTIVE):
                    candidates.append(frame)
            if len(candidates) == 1:
                self.frame = candidates[0]

    def refresh(self):
        self.pending = 0
        if self.context.get('id') != 'browser':
            return False
        try:
            if self.frame is None:
                self.bind()
            if self.frame is None:
                self.emit({'ready': False, 'diagnostic': 'unbound', 'pid': self.target_pid})
                return False
            self.controls, urls = scan(self.frame)
            field = self.controls.get('urlbar-input')
            # Prefer committed DocURL; the field can contain an unfinished edit.
            url = urls[0] if len(urls) == 1 else (Atspi.Text.get_text(field, 0, -1) if field else '')
            busy = loading(self.controls)
            self.emit({'ready': field is not None or len(urls) == 1, 'url': url, 'busy': busy,
                       'back': enabled(self.controls.get('back-button')),
                       'forward': enabled(self.controls.get('forward-button')),
                       'reload': enabled(self.controls.get('reload-button')) or busy})
        except (GLib.Error, subprocess.SubprocessError, ValueError):
            self.frame, self.controls = None, {}
            self.emit({'ready': False})
        return False

    def action(self, message):
        name = message.get('action')
        if name not in SHORTCUTS:
            self.result(message, False, 'Acción no disponible. Usa la barra de direcciones del navegador.')
            return
        if message.get('revision') != self.context.get('revision'):
            self.result(message, False, 'La ventana cambió; vuelve a seleccionar el navegador.')
            return
        if not unexpired(message):
            self.result(message, False, 'La acción caducó; vuelve a intentarlo.')
            return
        try:
            # QML first waits for real Wayland keyboard focus. Recheck here,
            # immediately before delivery; never target the active window by
            # wildcard, and never inject URL text into the global keyboard.
            active = hypr('activewindow')
            if not target_matches(self.context, active, self.target_pid):
                self.result(message, False, 'Vuelve a seleccionar la ventana del navegador.')
                return
            self.target_pid = active['pid']
            if name in NATIVE_BUTTONS and self.frame is not None:
                try:
                    self.controls, _ = scan(self.frame)
                    control = self.controls.get(NATIVE_BUTTONS[name])
                    if enabled(control) and control.get_process_id() == self.target_pid:
                        count = Atspi.Action.get_n_actions(control)
                        if count > 0 and unexpired(message) and target_matches(self.context, hypr('activewindow'), self.target_pid):
                            index = next((i for i in range(count)
                                          if Atspi.Action.get_action_name(control, i) in ('click', 'press', 'activate')), 0)
                            if Atspi.Action.do_action(control, index):
                                self.result(message, True, method='native-button')
                                self.schedule()
                                return
                except GLib.Error:
                    # Toolbar customizations may remove an accessible button.
                    # Its native keyboard fallback still works without AT-SPI.
                    pass
            if not unexpired(message):
                self.result(message, False, 'La acción caducó; vuelve a intentarlo.')
                return
            if not target_matches(self.context, hypr('activewindow'), self.target_pid):
                self.result(message, False, 'La ventana perdió el foco antes de recibir la acción.')
                return
            directed_shortcut(self.context['windowAddress'], *SHORTCUTS[name])
            notice = {'extensions': 'Atajo enviado al gestor nativo de extensiones.',
                      'menu': 'Atajo enviado a la barra de menús nativa.'}.get(name, '')
            self.result(message, True, notice, 'directed-shortcut')
            self.schedule()
        except (GLib.Error, subprocess.SubprocessError, OSError, ValueError, RuntimeError):
            self.result(message, False, 'El navegador no recibió la acción. Vuelve a intentarlo.')


if __name__ == '__main__':
    Bridge()
    Atspi.event_main()
