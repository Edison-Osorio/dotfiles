-- Terminales flotantes de los menús de red, bluetooth y audio (launch-tui)
hl.window_rule({
  name = "tui-float",
  match = { class = "^tui-float$" },
  float = true,
  move = "(monitor_w-window_w-12) 46",
})
