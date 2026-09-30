import QtQuick
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland

Item {
  id: root
  required property var context
  property var snapshot: ({})
  property string error: ""
  property var lastResult: ({})
  property int nextRequestId: 0
  property var pendingRequest: null
  property bool requestSent: false
  property int focusAttempts: 0
  readonly property bool actionPending: pendingRequest !== null
  readonly property bool available: context.id === "browser" && !!context.windowAddress && worker.running
  readonly property bool ready: context.id === "browser" && snapshot.revision === context.revision && snapshot.ready === true
  readonly property string url: ready ? (snapshot.url || "") : ""
  readonly property bool back: ready && snapshot.back === true
  readonly property bool forward: ready && snapshot.forward === true
  readonly property bool reload: ready && snapshot.reload === true
  readonly property bool busy: ready && snapshot.busy === true
  signal actionFinished(int requestId, int revision, bool delivered, string message)

  function send(value) {
    if (!worker.running) return false
    worker.write(JSON.stringify(value) + "\n")
    return true
  }
  function syncTarget() {
    if (pendingRequest && pendingRequest.revision !== context.revision)
      finish(false, "La ventana cambió antes de completar la acción.")
    send({ type: "focus", context: { id: context.id, appId: context.appId, pid: context.pid,
      windowAddress: context.windowAddress, revision: context.revision } })
  }
  function action(name, revision, value) {
    if (!available || actionPending || context.revision !== revision) return false
    if (["back", "forward", "reload", "stop", "native-address", "menu", "extensions",
      "downloads", "history", "bookmarks", "new-tab"].indexOf(name) === -1) {
      error = "Acción no disponible. Usa la barra de direcciones del navegador."
      return false
    }
    error = ""
    requestSent = false
    focusAttempts = 0
    pendingRequest = { type: "action", action: name, revision: revision, requestId: ++nextRequestId,
      expiresAtMs: Date.now() + 4000 }
    deliveryTimeout.restart()
    dispatchWhenFocused.restart()
    return true // Accepted into the queue; actionFinished acknowledges delivery.
  }
  function finish(delivered, message) {
    if (!pendingRequest) return
    var request = pendingRequest
    pendingRequest = null
    requestSent = false
    deliveryTimeout.stop()
    dispatchWhenFocused.stop()
    if (!delivered) error = message || "No se pudo entregar la acción al navegador."
    actionFinished(request.requestId, request.revision, delivered, message || "")
  }
  function dispatchFocused() {
    if (!pendingRequest || requestSent) return
    if (context.revision !== pendingRequest.revision || context.id !== "browser") {
      finish(false, "La ventana cambió antes de recibir la acción.")
      return
    }
    var focused = Hyprland.activeToplevel
    var wayland = ToplevelManager.activeToplevel
    // activeToplevel can retain the last application while a layer owns the
    // keyboard. Wait for its actual Wayland handle, not a guessed delay.
    if (focused && String(focused.address) === String(context.windowAddress)
        && focused.wayland && focused.wayland === wayland) {
      syncTarget()
      requestSent = send(pendingRequest)
      if (!requestSent) finish(false, "El adaptador del navegador se está reiniciando.")
      dispatchWhenFocused.stop()
    } else if (wayland || ++focusAttempts >= 27) {
      finish(false, "Vuelve a seleccionar el navegador para usar este control.")
    }
  }
  onContextChanged: syncTarget()
  Timer { interval: 500; running: true; repeat: true; onTriggered: root.syncTarget() }
  Timer { id: dispatchWhenFocused; interval: 30; repeat: true; onTriggered: root.dispatchFocused() }
  Timer {
    id: deliveryTimeout
    interval: 5000
    onTriggered: root.finish(false, "El navegador tardó demasiado en recibir la acción.")
  }
  Process {
    id: worker
    command: ["python3", "-u", Qt.resolvedUrl("browser_bridge.py").toString().replace("file://", "")]
    running: true
    stdinEnabled: true
    onStarted: root.syncTarget()
    stdout: SplitParser {
      onRead: function(line) {
        try {
          var value = JSON.parse(line)
          if (value.type === "action-result") {
            if (root.pendingRequest && value.requestId === root.pendingRequest.requestId
                && value.revision === root.pendingRequest.revision) {
              root.lastResult = value
              root.finish(value.delivered === true, value.message || "")
            }
            return
          }
          if (value.revision !== root.context.revision) return
          if (value.type === "error") root.error = value.message
          else root.snapshot = value
        } catch (e) { console.warn("Browser bridge: invalid state") }
      }
    }
    stderr: SplitParser { onRead: function(line) { console.warn("Browser adapter: " + line) } }
    onExited: {
      root.snapshot = ({})
      root.finish(false, "El adaptador del navegador se está reiniciando.")
      retry.restart()
    }
  }
  Timer { id: retry; interval: 3000; onTriggered: worker.running = true }
}
