-- Terminales flotantes de los menús de red, bluetooth y audio (launch-tui)
hl.window_rule({
  name = "tui-float",
  match = { class = "^tui-float$" },
  float = true,
  move = "(monitor_w-window_w-12) 46",
})

-- Cámara web superpuesta al grabar pantalla (eoshell-capture-screenrecording --with-webcam).
-- Ventana flotante fija en la esquina inferior derecha; el tamaño depende de la altura del monitor.
local cam = {
  small  = { w = "(monitor_h*4/25)", h = "(monitor_h*9/50)" },
  medium = { w = "(monitor_h*2/9)",  h = "(monitor_h/4)" },
  large  = { w = "(monitor_h*3/10)", h = "(monitor_h*27/80)" },
}
for name, d in pairs(cam) do
  hl.window_rule({
    name = "webcam-overlay-" .. name,
    match = { class = "^WebcamOverlay-" .. name .. "$", title = "^WebcamOverlay$" },
    float = true,
    pin = true,
    no_initial_focus = true,
    no_dim = true,
    size = d.w .. " " .. d.h,
    move = "(monitor_w-" .. d.w .. "-40) (monitor_h-" .. d.h .. "-40)",
  })
end
