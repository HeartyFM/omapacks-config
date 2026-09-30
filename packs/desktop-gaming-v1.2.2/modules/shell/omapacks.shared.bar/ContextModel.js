// Version 1: explicit application opt-in; titles never select a context.
function object(value) {
  return !!value && typeof value === "object" && !Array.isArray(value)
}
function strings(value) {
  return Array.isArray(value) ? value.filter(function(v) { return typeof v === "string" && v.trim() !== "" }).map(function(v) { return v.trim() }) : []
}
function normalize(value) {
  var result = { enabled: false, contexts: [] }
  if (!object(value) || value.version !== 1 || value.enabled !== true) return result
  result.enabled = true
  var ids = {}
  var rows = Array.isArray(value.contexts) ? value.contexts : []
  for (var i = 0; i < rows.length; i++) {
    var row = rows[i]
    if (!object(row) || row.enabled === false || typeof row.id !== "string"
        || !/^[a-z][a-z0-9.-]*$/.test(row.id) || row.id === "default" || ids[row.id]) continue
    var apps = object(row.match) ? strings(row.match.appIds).map(function(s) { return s.toLowerCase() }) : []
    if (!apps.length) continue
    ids[row.id] = true
    result.contexts.push({ id: row.id, label: typeof row.label === "string" ? row.label : row.id,
      appIds: apps, priority: typeof row.priority === "number" && isFinite(row.priority) ? row.priority : 0,
      order: i })
  }
  result.contexts.sort(function(a, b) { return b.priority - a.priority || a.order - b.order })
  return result
}
function match(config, appId) {
  if (!config || !config.enabled) return { id: "default", label: "Omarchy" }
  var app = String(appId || "").toLowerCase()
  for (var i = 0; i < config.contexts.length; i++) {
    if (config.contexts[i].appIds.indexOf(app) !== -1) return config.contexts[i]
  }
  return { id: "default", label: "Omarchy" }
}
function visible(entry, contextId, enabled) {
  var when = object(entry) && object(entry.when) ? entry.when : null
  if (!when) return true // Existing Omarchy widgets remain unconditional.
  var current = enabled ? contextId : "default"
  if (Array.isArray(when.contexts) && strings(when.contexts).indexOf(current) === -1) return false
  if (Array.isArray(when.exceptContexts) && strings(when.exceptContexts).indexOf(current) !== -1) return false
  return true
}
// A layer panel can temporarily take keyboard focus. Never retain a closed
// window or carry its context to another workspace / a newly focused app.
function retain(previousExists, stillAlive, sameWorkspace, interacting, settling) {
  return !!(previousExists && stillAlive && sameWorkspace && (interacting || settling))
}
if (typeof module !== "undefined") module.exports = { normalize: normalize, match: match, visible: visible, retain: retain }
