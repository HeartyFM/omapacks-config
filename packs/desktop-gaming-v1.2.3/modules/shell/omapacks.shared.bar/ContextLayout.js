// Layouts reference existing slot IDs. A focus change moves the same widgets;
// it never constructs a second clock, tray, IPC handler or panel.
function regions(entries, override) {
  var result = { left: [], center: [], right: [] }, seen = {}
  var names = ["left", "center", "right"]
  names.forEach(function(region) {
    var ids = override && Array.isArray(override[region]) ? override[region] : null
    if (override && !ids) return
    if (ids) ids.forEach(function(id) {
      var index = entries.findIndex(function(e) { return e.id === id })
      if (index >= 0 && !seen[index]) { result[region].push(index); seen[index] = true }
    })
    else entries.forEach(function(e, i) { if (e.region === region) result[region].push(i) })
  })
  return result
}
function place(entries, groups, width, margin, anchor, flexId) {
  var result = entries.map(function() { return { x: 0, width: 0, visible: false, region: "" } })
  function size(i) { return entries[i].allowed ? entries[i].width : 0 }
  function total(list) { return list.reduce(function(n, i) { return n + size(i) }, 0) }
  function put(list, x) { list.forEach(function(i) {
    result[i] = { x: x, width: size(i), visible: entries[i].allowed, region: entries[i].region }
    x += size(i)
  }) }
  put(groups.left, margin)
  var rightStart = width - margin - total(groups.right)
  put(groups.right, rightStart)
  if (flexId && groups.center.length === 1 && entries[groups.center[0]].id === flexId) {
    var i = groups.center[0], start = margin + total(groups.left)
    result[i] = { x: start, width: Math.max(0, rightStart - start), visible: entries[i].allowed, region: "center" }
  } else {
    var centerWidth = total(groups.center), offset = centerWidth / 2
    var a = groups.center.findIndex(function(i) { return entries[i].id === anchor })
    if (a >= 0) offset = total(groups.center.slice(0, a)) + size(groups.center[a]) / 2
    put(groups.center, width / 2 - offset)
  }
  ;["left", "center", "right"].forEach(function(r) { groups[r].forEach(function(i) { result[i].region = r }) })
  return result
}
if (typeof module !== "undefined") module.exports = { regions: regions, place: place }
