local c = require("theme.colors")
local function rgba(hex, alpha) return "rgba(" .. hex .. alpha .. ")" end

hl.config({
  general = {
    layout = "dwindle",
    border_size = 2,
    gaps_in = 4,
    gaps_out = 10,
    col = {
      active_border = rgba(c.lavender, "ee"),
      inactive_border = rgba(c.surface1, "aa"),
    },
  },
  decoration = {
    rounding = 8,
    blur = { enabled = true, size = 5, passes = 2 },
    shadow = { enabled = false },
  },
  dwindle = { preserve_split = true },
  misc = {
    disable_hyprland_logo = true,
    background_color = "rgb(" .. c.base .. ")",
  },
})

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "easeOutQuint", style = "popin" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 2, bezier = "default" })
