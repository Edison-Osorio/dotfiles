local main = "SUPER"
local terminal = "kitty"
local launcher = "rofi -show drun"

local function run(keys, cmd, opts) hl.bind(keys, hl.dsp.exec_cmd(cmd), opts) end

-- Aplicaciones
run(main .. " + RETURN", terminal)
run(main .. " + SPACE", launcher)
run(main .. " + E", "nautilus")
run(main .. " + W", "google-chrome-stable")
run(main .. " + SHIFT + M", "monitor-layout")
run(main .. " + SHIFT + I", "idle-settings")
run(main .. " + N", "swaync-client -t -sw")
run(main .. " + V", "clipboard-menu")

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
run("XF86AudioRaiseVolume", "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+", locked)
run("XF86AudioLowerVolume", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-", locked)
run("XF86AudioMute", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", { locked = true })
run("XF86AudioMicMute", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle", { locked = true })
run("XF86MonBrightnessUp", "brightnessctl set 5%+", locked)
run("XF86MonBrightnessDown", "brightnessctl set 5%-", locked)
run("XF86AudioPlay", "playerctl play-pause", { locked = true })
run("XF86AudioNext", "playerctl next", { locked = true })
run("XF86AudioPrev", "playerctl previous", { locked = true })

-- Cierra los menús flotantes (wifi/bluetooth/audio) al hacer clic fuera de ellos
run("mouse:272", "tui-close-outside", { non_consuming = true })
run("mouse:273", "tui-close-outside", { non_consuming = true })
