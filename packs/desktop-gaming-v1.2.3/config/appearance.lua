-- Apariencia portable de Diego; mantiene monitores, entrada y atajos del equipo.
hl.config({
  general = {
    border_size = 1,
    col = {
      active_border = "rgba(b8b8b880)",
      inactive_border = "rgba(88888840)",
    },
  },
  group = {
    col = {
      border_active = "rgba(b8b8b880)",
      border_inactive = "rgba(88888840)",
    },
  },
  decoration = {
    rounding = 0,
    blur = {
      enabled = true,
      size = 6,
      passes = 2,
      vibrancy = 0.0,
      contrast = 0.92,
      brightness = 1.0,
    },
  },
})

-- Include native shell cards and their dropdowns/tooltips. Ignore the
-- faint fullscreen scrim; blur only the actual glass surfaces.
hl.layer_rule({
  name = "omarchy-glass-surfaces",
  match = { namespace = "^omarchy-(bar|menu|notifications|keyboard-panel|osd|clipboard|emojis|reminders|polkit|network-qr|network-speedtest|disk-speedtest|image-selector|lock-preview)$" },
  blur = true,
  blur_popups = true,
  ignore_alpha = 0.10,
})

-- Native terminal transparency affects backgrounds only. Avoid multiplying
-- it by Omarchy's default whole-window opacity (including text).
o.window({ tag = "terminal" }, { opacity = "1 override 1 override 1 override" })

-- Keep workspace transitions smooth (400 ms) while moving vertically.
-- Horizontal slides expose off-screen columns from the scrolling layout due
-- to a Hyprland renderer bug; vertical motion keeps those columns clipped.
hl.animation({
  leaf = "workspaces",
  enabled = true,
  speed = 4,
  bezier = "easeOutQuint",
  style = "slidevert",
})

-- OmaFiles paints glass in its background; keep text and icons fully opaque.
hl.window_rule({
  name = "omafiles-glass-text",
  match = { class = "^dev\\.omarchy\\.omafiles$" },
  opacity = "1 override 1 override 1 override",
})

-- Spotify's personal client paints translucent backgrounds and solid artwork.
hl.window_rule({
  name = "spotify-glass-text",
  match = { class = "^[Ss]potify$" },
  opacity = "1 override 1 override 1 override",
})

-- Mantener el cursor visible, sin imponer el renderizador de la Surface.
hl.config({ cursor = { hide_on_key_press = false, hide_on_touch = false } })
