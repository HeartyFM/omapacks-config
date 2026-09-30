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
      model: [
        { action: "downloads", icon: "󰇚", label: "Descargas · Ctrl+Shift+Y" },
        { action: "extensions", icon: "󰏗", label: "Extensiones de Firefox" },
        { action: "menu", icon: "󰍜", label: "Herramientas de Firefox · F10" }
      ]
      WidgetButton {
        required property var modelData
        bar: root.bar
        text: modelData.icon
        fixedWidth: Style.bar.iconSlot
        fontSize: Style.font.body
        dimmed: !root.bridge?.available
        pressable: !dimmed && !root.bridge?.actionPending
        tooltipText: root.bridge?.error || modelData.label
        onPressed: function(button) { if (button === Qt.LeftButton) root.dispatch(modelData.action) }
      }
    }
  }
}
