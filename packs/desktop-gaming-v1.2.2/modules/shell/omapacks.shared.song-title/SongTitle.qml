import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Artists.js" as Artists

BarWidget {
  id: root
  moduleName: "omapacks.shared.song-title"

  readonly property var mediaService: bar?.shell?.firstPartyServiceFor("omarchy.media")
  readonly property var activePlayer: mediaService ? mediaService.activePlayer : null
  readonly property string title: activePlayer ? String(activePlayer.trackTitle || "") : ""
  readonly property var metadata: activePlayer ? (activePlayer.metadata || {}) : ({})
  readonly property string spotifyTrackId: Artists.spotifyTrackId(metadata)
  readonly property var nativeArtistNames: Artists.nativeArtists(metadata,
    activePlayer ? String(activePlayer.trackArtists || activePlayer.trackArtist || "") : "")
  readonly property var artistNames: spotifyTrackId !== "" && resolvedTrackId === spotifyTrackId
    && resolvedArtists.length ? resolvedArtists : nativeArtistNames
  readonly property string artist: artistNames.join(", ")
  readonly property string displayText: title + (artist ? " · " + artist : "")
  readonly property var hostWindow: root.QsWindow.window
  property bool controlsShown: false
  readonly property bool interactionInside: widgetHover.hovered
    || previousControl.tooltipHovered || playControl.tooltipHovered || nextControl.tooltipHovered
    || previousControl.activeFocus || playControl.activeFocus || nextControl.activeFocus
  readonly property real controlGap: Style.spacing.lg
  readonly property real controlWidth: Math.max(1, Math.min(Style.space(34),
    Math.floor((width - 2 * gap - 2 * controlGap) / 3)))

  onInteractionInsideChanged: {
    controlsHideTimer.stop()
    if (interactionInside) controlsShown = true
    else controlsHideTimer.restart()
  }

  function canPerform(action) {
    var player = activePlayer
    if (!player) return false
    if (action === "previous") return !!player.canGoPrevious
    if (action === "next") return !!player.canGoNext
    return !!(player.canTogglePlaying || (player.isPlaying ? player.canPause : player.canPlay))
  }

  function perform(action) {
    if (!mediaService || !canPerform(action)) return false
    return mediaService.runAction(action, false, mediaService.playerKey(activePlayer))
  }

  function controlGeometry(control) {
    var point = control.mapToItem(null, 0, 0)
    return {x: point.x, y: point.y, width: control.width, height: control.height}
  }
  readonly property real gap: Style.spacing.controlPaddingX
  readonly property real availableWidth: computeAvailableWidth()

  property var artistCache: ({})
  property var resolvedArtists: []
  property string resolvedTrackId: ""
  property string artistSource: "native"
  property var artistRequest: null
  property int requestSerial: 0

  function cancelArtistRequest() {
    requestSerial++
    artistTimeout.stop()
    if (artistRequest) artistRequest.abort()
    artistRequest = null
  }

  // Spotify's Linux MPRIS interface can expose only the first credited artist.
  // Its public embed page includes the complete ordered list, without login.
  function refreshArtists() {
    cancelArtistRequest()
    resolvedTrackId = ""
    resolvedArtists = []
    artistSource = "native"
    var id = spotifyTrackId
    if (!id) return
    if (artistCache[id]) {
      resolvedArtists = artistCache[id]
      resolvedTrackId = id
      artistSource = "spotify-public"
      return
    }
    var serial = requestSerial
    var request = new XMLHttpRequest()
    artistRequest = request
    artistSource = "loading"
    request.onreadystatechange = function() {
      if (serial !== root.requestSerial || id !== root.spotifyTrackId
          || request.readyState !== XMLHttpRequest.DONE) return
      artistTimeout.stop()
      root.artistRequest = null
      var names = request.status === 200 ? Artists.parseSpotifyArtists(request.responseText, id) : []
      if (names.length) {
        var cache = Object.assign({}, root.artistCache)
        var keys = Object.keys(cache)
        if (keys.length >= 100) delete cache[keys[0]]
        cache[id] = names
        root.artistCache = cache
        root.resolvedArtists = names
        root.resolvedTrackId = id
        root.artistSource = "spotify-public"
      } else {
        root.artistSource = "native-unavailable"
      }
    }
    request.open("GET", "https://open.spotify.com/embed/track/" + id)
    artistTimeout.restart()
    request.send()
  }

  onSpotifyTrackIdChanged: refreshArtists()
  Component.onCompleted: refreshArtists()
  Timer {
    id: artistTimeout
    interval: 8000
    onTriggered: {
      root.cancelArtistRequest()
      root.artistSource = "native-unavailable"
    }
  }

  // The clock stays centered. Count the FULL indicator strip, even while its
  // inactive controls are concealed, so revealing them never moves this label.
  // Scope slots to this monitor; another monitor may have a different width.
  function computeAvailableWidth() {
    if (!bar || !hostWindow || vertical) return 0
    var centerEntries = bar.layoutEntries("center")
    var anchorIndex = bar.entryIndex(centerEntries, bar.centerAnchor)
    var leftWidth = Style.space(8)
    var beforeWidth = 0
    var centerWidth = 0
    var anchorWidth = 0
    var slots = bar.moduleSlots
    for (var i = 0; i < slots.length; i++) {
      var slot = slots[i]
      if (!slot || !slot.activeItem || slot.activeItem === root
          || !bar.targetBelongsToWindow(slot.activeItem, hostWindow)) continue
      if (slot.region === "left") {
        leftWidth += slot.width
      } else if (slot.region === "center") {
        var reserved = slot.width
        if (slot.activeItem.indicatorEntries !== undefined)
          reserved = Math.max(reserved, slot.activeItem.indicatorEntries.length * Style.bar.statusSlot)
        centerWidth += reserved
        var index = bar.entryIndex(centerEntries, slot.moduleName)
        if (index === anchorIndex) anchorWidth = reserved
        else if (index >= 0 && index < anchorIndex) beforeWidth += reserved
      }
    }
    var centerLeft = hostWindow.width / 2 - (anchorIndex >= 0
      ? anchorWidth / 2 + beforeWidth : centerWidth / 2)
    return Math.max(0, Math.floor(centerLeft - leftWidth - gap))
  }

  visible: title !== "" && !vertical && availableWidth >= Style.font.body * 4
  implicitWidth: visible ? availableWidth : 0
  implicitHeight: barSize

  Accessible.role: Accessible.Grouping
  Accessible.name: displayText

  // One persistent texture: changing from a short title to a long title must
  // never hide the source item or switch between two rendering pipelines.
  Item {
    id: viewport
    anchors.fill: parent
    anchors.leftMargin: root.gap
    anchors.rightMargin: root.gap
    clip: true
    readonly property real edgeFade: Math.min(Style.space(18), width / 4)
    readonly property bool overflowing: label.implicitWidth > width - 2 * edgeFade
    opacity: root.controlsShown ? 0 : 1
    Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutSine } }
    layer.enabled: true
    layer.smooth: true
    layer.effect: ShaderEffect {
      property real fadeFraction: viewport.edgeFade / Math.max(1, viewport.width)
      property real fadeStrength: viewport.overflowing ? 1 : 0
      fragmentShader: Qt.resolvedUrl("edge-fade.frag.qsb")
    }

    Text {
      id: label
      anchors.verticalCenter: parent.verticalCenter
      x: viewport.overflowing ? viewport.edgeFade / 2 : Math.round((parent.width - implicitWidth) / 2)
      text: root.displayText
      textFormat: Text.PlainText
      wrapMode: Text.NoWrap
      color: root.bar ? root.bar.barForeground : Color.bar.text
      font.family: root.bar ? root.bar.fontFamily : Style.font.family
      font.pixelSize: Style.font.body
    }
  }

  Row {
    id: controls
    anchors.centerIn: parent
    spacing: root.controlGap
    opacity: root.controlsShown ? 1 : 0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutSine } }

    MediaControl {
      id: previousControl
      action: "previous"
      text: "󰒮"
      tooltipText: "Anterior"
    }
    MediaControl {
      id: playControl
      action: "playPause"
      text: root.activePlayer && root.activePlayer.isPlaying ? "󰏤" : "󰐊"
      tooltipText: root.activePlayer && root.activePlayer.isPlaying ? "Pausar" : "Reproducir"
    }
    MediaControl {
      id: nextControl
      action: "next"
      text: "󰒭"
      tooltipText: "Siguiente"
    }
  }

  component MediaControl: BarIconButton {
    id: control
    required property string action
    bar: root.bar
    fixedWidth: root.controlWidth
    fixedHeight: root.barSize
    width: implicitWidth
    height: implicitHeight
    fontSize: Style.font.icon
    interactive: root.controlsShown && root.canPerform(action)
    dimmed: !root.canPerform(action)
    activeFocusOnTab: root.controlsShown
    Accessible.role: Accessible.Button
    Accessible.name: tooltipText
    Accessible.onPressAction: if (interactive) root.perform(action)
    Keys.onReturnPressed: if (interactive) root.perform(action)
    Keys.onEnterPressed: if (interactive) root.perform(action)
    Keys.onSpacePressed: if (interactive) root.perform(action)
    Keys.onEscapePressed: focus = false
    onPressed: function(button) { if (button === Qt.LeftButton) root.perform(action) }

    Rectangle {
      anchors.fill: parent
      z: -1
      radius: Style.cornerRadius
      color: control.tooltipHovered || control.activeFocus
        ? Style.hoverFillFor(control.foreground, Color.accent) : "transparent"
      border.width: control.activeFocus ? Style.spacing.hairline : 0
      border.color: Color.accent
    }
  }

  HoverHandler { id: widgetHover }
  Timer {
    id: controlsHideTimer
    interval: 100
    onTriggered: if (!root.interactionInside) root.controlsShown = false
  }
  onDisplayTextChanged: if (bar) bar.hideTooltip(root)
  Component.onDestruction: {
    cancelArtistRequest()
    if (bar) bar.hideTooltip(root)
  }

  IpcHandler {
    target: "omapacks.shared.song-title"
    function previous(): bool { return root.perform("previous") }
    function playPause(): bool { return root.perform("playPause") }
    function next(): bool { return root.perform("next") }
    function status(): string {
      return JSON.stringify({title: root.title, artist: root.artist, artists: root.artistNames,
        artistSource: root.artistSource, spotifyTrackId: root.spotifyTrackId, displayText: root.displayText,
        width: root.width, availableWidth: root.availableWidth,
        overflowing: viewport.overflowing, fontSize: label.font.pixelSize,
        hovered: root.interactionInside, controlsShown: root.controlsShown,
        textOpacity: viewport.opacity, controlsOpacity: controls.opacity,
        controlRects: {previous: root.controlGeometry(previousControl),
          playPause: root.controlGeometry(playControl), next: root.controlGeometry(nextControl)},
        tooltipShown: root.bar ? root.bar.tooltipShown : false})
    }
  }
}
