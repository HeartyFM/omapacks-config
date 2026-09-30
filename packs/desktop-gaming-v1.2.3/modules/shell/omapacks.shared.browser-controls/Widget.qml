import QtQuick
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  readonly property var bridge: bar ? bar.browser : null
  property int capturedRevision: -1
  implicitWidth: row.implicitWidth
  implicitHeight: barSize
  function dispatch(action) {
    if (!bar || !bridge || !bridge.available || bridge.actionPending) return
    capturedRevision = bar.dynamicContext.revision
    if (!bar.holdContext(root)) return
    if (!bar.activateContext(capturedRevision) || !bridge.action(action, capturedRevision)) release()
  }
  function release() {
    if (bar) bar.releaseContext(root)
    capturedRevision = -1
  }
  Component.onDestruction: release()
  Connections {
    target: root.bridge
    function onActionFinished(requestId, revision, delivered, message) {
      if (root.capturedRevision === revision) root.release()
    }
  }
  Connections {
    target: root.bar
    function onDynamicContextChanged() {
      if (root.capturedRevision !== -1 && root.bar.dynamicContext.revision !== root.capturedRevision) root.release()
    }
  }
  Row {
    id: row
    Repeater {
      model: [ { action: "reload", icon: "󰑐", label: "Recargar · Ctrl+R" },
        { action: "back", icon: "󰁍", label: "Atrás · Alt+←" },
        { action: "forward", icon: "󰁔", label: "Adelante · Alt+→" } ]
      WidgetButton {
        required property var modelData
        readonly property bool stopping: modelData.action === "reload" && !!root.bridge?.busy
        bar: root.bar
        text: stopping ? "󰅖" : modelData.icon
        fixedWidth: Style.space(30)
        fontSize: Style.font.body
        dimmed: !root.bridge?.available || (modelData.action !== "reload" && !root.bridge?.[modelData.action])
        pressable: !dimmed && !root.bridge?.actionPending
        tooltipText: root.bridge?.error || (stopping ? "Detener carga · Esc" : modelData.label)
        onPressed: function(button) {
          if (button === Qt.LeftButton) root.dispatch(stopping ? "stop" : modelData.action)
        }
      }
    }
  }
}
