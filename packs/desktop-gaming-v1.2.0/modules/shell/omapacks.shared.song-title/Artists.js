// Read data only: never evaluate scripts embedded in Spotify's public page.
function nativeArtists(metadata, fallback) {
  var list = metadata ? metadata["xesam:artist"] : null
  var names = []
  if (typeof list === "string") list = [list]
  if (list && typeof list.length === "number") {
    for (var i = 0; i < list.length; i++) {
      var name = String(list[i] || "").trim()
      if (name) names.push(name)
    }
  }
  if (names.length) return names
  var text = String(fallback || "").trim()
  return text ? [text] : []
}

function spotifyTrackId(metadata) {
  if (!metadata) return ""
  var url = String(metadata["xesam:url"] || "")
  var match = /^https:\/\/open\.spotify\.com\/(?:intl-[a-z]+\/)?track\/([A-Za-z0-9]{22})(?:[/?#]|$)/.exec(url)
    || /^spotify:track:([A-Za-z0-9]{22})$/.exec(url)
    || /^\/com\/spotify\/track\/([A-Za-z0-9]{22})$/.exec(String(metadata["mpris:trackid"] || ""))
  return match ? match[1] : ""
}

function parseSpotifyArtists(html, expectedId) {
  if (!/^[A-Za-z0-9]{22}$/.test(expectedId)) return []
  var match = /<script\b[^>]*\bid=["']__NEXT_DATA__["'][^>]*>([\s\S]*?)<\/script\s*>/i.exec(String(html || ""))
  if (!match) return []
  try {
    var data = JSON.parse(match[1])
    var entity = data.props.pageProps.state.data.entity
    if (entity.uri !== "spotify:track:" + expectedId || !Array.isArray(entity.artists)) return []
    return entity.artists.map(function(artist) {
      return artist && typeof artist.name === "string" ? artist.name.trim() : ""
    }).filter(function(name) { return name !== "" })
  } catch (error) {
    return []
  }
}
