local main = "SUPER"
local terminal = "kitty"

local function run(keys, cmd, opts) hl.bind(keys, hl.dsp.exec_cmd(cmd), opts) end

-- Aplicaciones
run(main .. " + RETURN", terminal)
-- Lanzador y menú de eoshell (Quickshell); necesitan el shell corriendo (eoshell-run start).
-- Hyprland no hereda PATH ni EOSHELL_PATH, por eso va todo con ruta completa.
local eoshell = "env EOSHELL_PATH=/home/eosorio/dotfiles/quickshell /home/eosorio/dotfiles/quickshell/bin/eoshell-shell"
run(main .. " + SPACE", eoshell .. " eoshell.dock apps")
run(main .. " + ALT + SPACE", eoshell .. " shell toggle eoshell.menu '{\"menu\":\"root\"}'")
run(main .. " + E", "nautilus")
run(main .. " + W", "google-chrome-stable")
run(main .. " + SHIFT + M", "monitor-layout")
run(main .. " + SHIFT + I", "idle-settings")
run(main .. " + N", eoshell .. " notifications showHistory")
run(main .. " + SHIFT + N", eoshell .. " notifications dismissAll")
-- Portapapeles del shell (eoshell); el de rofi/cliphist queda en Super+Shift+V como respaldo.
run(main .. " + V", eoshell .. " shell toggle eoshell.clipboard")
run(main .. " + SHIFT + V", "clipboard-menu")

-- Ventanas
hl.bind(main .. " + Q", hl.dsp.window.close())
hl.bind(main .. " + F", hl.dsp.window.fullscreen())
hl.bind(main .. " + A", hl.dsp.window.float())
hl.bind(main .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(main .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Sesión
run(main .. " + CTRL + L", "hyprlock")
run(main .. " + ESCAPE", "power-menu")
run(main .. " + SHIFT + X", "wlogout")
hl.bind(main .. " + SHIFT + E", hl.dsp.exit())

-- Foco y movimiento (flechas y hjkl)
local dirs = { { "H", "LEFT", "l" }, { "L", "RIGHT", "r" }, { "K", "UP", "u" }, { "J", "DOWN", "d" } }
for _, d in ipairs(dirs) do
  hl.bind(main .. " + " .. d[1], hl.dsp.focus({ direction = d[3] }))
  hl.bind(main .. " + " .. d[2], hl.dsp.focus({ direction = d[3] }))
  hl.bind(main .. " + SHIFT + " .. d[1], hl.dsp.window.move({ direction = d[3] }))
  hl.bind(main .. " + SHIFT + " .. d[2], hl.dsp.window.move({ direction = d[3] }))
end

-- Espacios de trabajo 1-9
for i = 1, 9 do
  hl.bind(main .. " + " .. i, hl.dsp.focus({ workspace = tostring(i) }))
  hl.bind(main .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = tostring(i) }))
end

-- Capturas (Print = región con editor, Shift+Print = pantalla completa, Ctrl+Print = ventana activa)
run("Print", "screenshot region")
run("SUPER + SHIFT + S", "screenshot region")
run("SHIFT + Print", "screenshot screen")
run("CTRL + Print", "screenshot window")

-- Volumen, brillo y multimedia (funcionan con la pantalla bloqueada)
local locked = { locked = true, repeating = true }
-- osd-ctl cambia el volumen/brillo y muestra el indicador de eoshell (ruta completa: Hyprland no hereda PATH)
local osd = "/home/eosorio/dotfiles/hyprland/bin/osd-ctl"
run("XF86AudioRaiseVolume", osd .. " volume up", locked)
run("XF86AudioLowerVolume", osd .. " volume down", locked)
run("XF86AudioMute", osd .. " volume mute", { locked = true })
run("XF86AudioMicMute", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle", { locked = true })
run("XF86MonBrightnessUp", osd .. " brightness up", locked)
run("XF86MonBrightnessDown", osd .. " brightness down", locked)
run("XF86AudioPlay", "playerctl play-pause", { locked = true })
run("XF86AudioNext", "playerctl next", { locked = true })
run("XF86AudioPrev", "playerctl previous", { locked = true })

-- Cierra los menús flotantes (wifi/bluetooth/audio) al hacer clic fuera de ellos
run("mouse:272", "tui-close-outside", { non_consuming = true })
run("mouse:273", "tui-close-outside", { non_consuming = true })
