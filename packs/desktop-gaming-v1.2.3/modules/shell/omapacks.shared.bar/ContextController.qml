import QtQuick
import Quickshell.Hyprland
import Quickshell.Wayland
import "ContextModel.js" as Model

Item {
  id: root
  property var configuration: ({})
  property bool interactionActive: false
  readonly property var config: Model.normalize(configuration)
  property var targetWindow: null
  property var holds: []
  property int revision: 0
  readonly property var focusedWindow: Hyprland.activeToplevel
  readonly property var waylandFocus: ToplevelManager.activeToplevel
  readonly property var windows: Hyprland.toplevels.values
  readonly property var workspace: Hyprland.focusedWorkspace
  readonly property var monitor: Hyprland.focusedMonitor
  readonly property string appId: targetWindow ? String(targetWindow.wayland?.appId || targetWindow.lastIpcObject?.class || "") : ""
  readonly property string windowTitle: targetWindow ? String(targetWindow.title || "") : ""
  readonly property string windowAddress: targetWindow ? String(targetWindow.address || "") : ""
  readonly property var selected: Model.match(config, appId)
  readonly property string contextId: selected.id
  readonly property bool holding: interactionActive || holds.length > 0
  readonly property var state: ({ version: 1, enabled: config.enabled, id: contextId,
    label: selected.label, appId: appId, title: windowTitle, windowAddress: windowAddress,
    pid: targetWindow?.lastIpcObject?.pid || 0,
    workspace: targetWindow?.workspace?.name || "", monitor: targetWindow?.monitor?.name || "",
    revision: revision, held: holding && !waylandFocus })

  function alive(window) { return !!window && windows.indexOf(window) !== -1 }
  function sameWorkspace(window) {
    return !!window && !!workspace && window.workspace === workspace
      && (!monitor || window.monitor === monitor)
  }
  function replaceTarget(next) {
    if (targetWindow === next) return
    holds = []
    targetWindow = next
    revision++ // Consumers must discard actions queued for an older revision.
  }
  function refresh(settled) {
    var next = focusedWindow
    // Hyprland can retain its last window while a layer has keyboard focus.
    // The Wayland handle tells us whether an application actually has focus.
    var hasFocus = !!next && (!next.wayland || next.wayland === waylandFocus)
    if (hasFocus && alive(next) && sameWorkspace(next)) {
      settleTimer.stop()
      replaceTarget(next)
      return
    }
    var keep = Model.retain(!!targetWindow, alive(targetWindow), sameWorkspace(targetWindow), holding, !settled)
    if (!keep) replaceTarget(null)
    if (!settled && targetWindow && !holding) settleTimer.restart()
  }
  function hold(owner) {
    if (!owner || !alive(targetWindow)) return false
    if (holds.indexOf(owner) === -1) holds = holds.concat([owner])
    return true
  }
  function release(owner) {
    holds = holds.filter(function(item) { return item !== owner })
    refresh(false)
  }
  function activate(expectedRevision) {
    if (expectedRevision !== revision || !alive(targetWindow) || !targetWindow.wayland) return false
    targetWindow.wayland.activate()
    return true
  }
  // The initial compositor snapshot arrives in several steps. Reconcile
  // again when a window acquires its Wayland handle/workspace/class.
  Connections {
    target: root.focusedWindow
    function onWaylandHandleChanged() { root.refresh(false) }
    function onLastIpcObjectChanged() { root.refresh(false) }
    function onWorkspaceChanged() { root.refresh(false) }
    function onMonitorChanged() { root.refresh(false) }
  }
  onFocusedWindowChanged: refresh(false)
  onWaylandFocusChanged: refresh(false)
  onWindowsChanged: refresh(false)
  onWorkspaceChanged: refresh(false)
  onMonitorChanged: refresh(false)
  onHoldingChanged: refresh(false)
  onConfigChanged: refresh(false)
  Component.onCompleted: refresh(false)
  Timer { id: settleTimer; interval: 120; onTriggered: root.refresh(true) }
}
