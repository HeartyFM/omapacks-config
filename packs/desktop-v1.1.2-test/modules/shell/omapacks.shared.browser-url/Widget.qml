import QtQuick
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  readonly property var bridge: bar ? bar.browser : null
  property int capturedRevision: -1
  readonly property bool loading: !!bridge && bridge.busy && visible && bar?.dynamicContext.id === "browser"
  property real pulseLevel: 1
  onLoadingChanged: {
    if (loading) { settlePulse.stop(); loadingPulse.restart() }
    else { loadingPulse.stop(); settlePulse.restart() }
  }
  SequentialAnimation {
    id: loadingPulse
    loops: Animation.Infinite
    NumberAnimation { target: root; property: "pulseLevel"; to: 0.48; duration: 650; easing.type: Easing.InOutSine }
    NumberAnimation { target: root; property: "pulseLevel"; to: 1; duration: 650; easing.type: Easing.InOutSine }
  }
  NumberAnimation {
    id: settlePulse
    target: root; property: "pulseLevel"; to: 1; duration: 160; easing.type: Easing.OutCubic
  }
  implicitWidth: Math.min(Style.space(620), Math.max(Style.space(190), urlLabel.implicitWidth + Style.space(24)))
  implicitHeight: barSize

  function openNativeAddress() {
    if (!bar || !bridge || !bridge.available || bridge.actionPending) return
    capturedRevision = bar.dynamicContext.revision
    if (!bar.holdContext(root)) return
    if (!bar.activateContext(capturedRevision) || !bridge.action("native-address", capturedRevision)) release()
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

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "Dirección"
    labelVisible: false
    pressable: !!root.bridge && root.bridge.available && !root.bridge.actionPending
    tooltipText: root.bridge?.error || ((root.bridge?.url || "Buscar o escribir una dirección") + "\nAbrir búsqueda de Firefox · Ctrl+L")
    onPressed: function(b) { if (b === Qt.LeftButton) root.openNativeAddress() }
    Text {
      id: urlLabel
      anchors.fill: parent
      anchors.leftMargin: Style.space(8)
      anchors.rightMargin: Style.space(8)
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      readonly property string currentUrl: root.bridge?.url || ""
      readonly property bool startPage: currentUrl === "about:newtab" || currentUrl === "about:home" || currentUrl === "about:blank"
      text: root.bridge?.error ? "No se pudo abrir · vuelve a intentar"
        : startPage || !currentUrl ? "Buscar o escribir una dirección" : currentUrl
      textFormat: Text.PlainText
      font.family: Style.font.family
      font.pixelSize: Style.font.body
      readonly property color baseColor: root.bridge?.error ? Color.urgent : button.tooltipHovered ? Color.accent : Color.bar.text
      color: Qt.rgba(baseColor.r * root.pulseLevel, baseColor.g * root.pulseLevel,
        baseColor.b * root.pulseLevel, baseColor.a)
      opacity: root.bridge?.available ? 1 : 0.55
      elide: Text.ElideRight
    }
  }
}
