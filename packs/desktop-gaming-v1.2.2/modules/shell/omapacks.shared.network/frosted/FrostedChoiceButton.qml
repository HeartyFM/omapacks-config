import QtQuick
import qs.Commons
import qs.Ui

// Light-theme glass controls for the display scale, Wi-Fi band, and DNS choices.
// The shared Button still owns input, tooltip, text, and keyboard behavior.
Button {
  id: root

  // Keep a persistent choice distinct from Button.selected: the user's global
  // selected-color token is pale and would make selected text hard to read.
  property bool pinned: false
  readonly property bool chosen: pinned || selected || active
  readonly property real fillAlpha: !enabled ? 0.05
    : chosen && hot ? Color.pickAlpha("diego-panels.chosen-hover-fill-alpha", 0.52)
    : chosen ? Color.pickAlpha("diego-panels.chosen-fill-alpha", 0.45)
    : hot ? Color.pickAlpha("diego-panels.hover-fill-alpha", 0.25)
    : Color.pickAlpha("diego-panels.normal-fill-alpha", 0.12)
  readonly property real borderAlpha: !enabled ? 0.12
    : chosen && hot ? Color.pickAlpha("diego-panels.chosen-hover-border-alpha", 1.00)
    : chosen ? Color.pickAlpha("diego-panels.chosen-border-alpha", 0.95)
    : hot ? Color.pickAlpha("diego-panels.hover-border-alpha", 0.80)
    : Color.pickAlpha("diego-panels.normal-border-alpha", 0.52)

  color: Util.alpha(Color.background, fillAlpha)
  borderSpec: Border.flat(Util.alpha(Color.accent, borderAlpha), 1)

  Rectangle {
    visible: root.chosen
    x: Style.space(3)
    anchors.verticalCenter: parent.verticalCenter
    width: Style.space(2)
    height: parent.height - Style.space(10)
    radius: 0
    color: Color.accent
  }
}
