-- Volume, brightness, keyboard backlight, and touchpad controls.
o.bind("XF86AudioRaiseVolume", "Volume up", { audio = "raise" }, { locked = true, repeating = true })
o.bind("XF86AudioLowerVolume", "Volume down", { audio = "lower" }, { locked = true, repeating = true })
o.bind("XF86AudioMute", "Mute", { audio = "mute-toggle" }, { locked = true })
o.bind("XF86AudioMicMute", "Mute microphone", "eoshell-audio-input-mute", { locked = true })
o.bind("XF86MonBrightnessUp", "Brightness up", { brightness = "raise" }, { locked = true, repeating = true })
o.bind("XF86MonBrightnessDown", "Brightness down", { brightness = "lower" }, { locked = true, repeating = true })
o.bind("SHIFT + XF86MonBrightnessUp", "Brightness maximum", "eoshell-brightness-display 100%", { locked = true, repeating = true })
o.bind("SHIFT + XF86MonBrightnessDown", "Brightness minimum", "eoshell-brightness-display 1%", { locked = true, repeating = true })
o.bind("XF86KbdBrightnessUp", "Keyboard brightness up", "eoshell-brightness-keyboard up", { locked = true, repeating = true })
o.bind("XF86KbdBrightnessDown", "Keyboard brightness down", "eoshell-brightness-keyboard down", { locked = true, repeating = true })
-- MacBooks have no keyboard-backlight keys. Ctrl and the display brightness
-- keys drive the keyboard backlight instead. The labels stay the short ones:
-- the keybindings menu elides a row past 78 characters.
o.bind("CTRL + XF86MonBrightnessDown", "Keyboard brightness down", "eoshell-brightness-keyboard down", { locked = true, repeating = true })
o.bind("CTRL + XF86MonBrightnessUp", "Keyboard brightness up", "eoshell-brightness-keyboard up", { locked = true, repeating = true })
o.bind("XF86KbdLightOnOff", "Keyboard backlight cycle", "eoshell-brightness-keyboard cycle", { locked = true })
o.bind_toggle("XF86TouchpadToggle", "Toggle touchpad", "touchpad", { locked = true })
o.bind("XF86TouchpadOn", "Enable touchpad", "eoshell-toggle-touchpad on", { locked = true })
o.bind("XF86TouchpadOff", "Disable touchpad", "eoshell-toggle-touchpad off", { locked = true })

-- Precise volume and brightness controls.
o.bind("ALT + XF86AudioRaiseVolume", "Volume up precise", "eoshell-audio-output-volume +1", { locked = true, repeating = true })
o.bind("ALT + XF86AudioLowerVolume", "Volume down precise", "eoshell-audio-output-volume -1", { locked = true, repeating = true })
o.bind("ALT + XF86MonBrightnessUp", "Brightness up precise", "eoshell-brightness-display +1%", { locked = true, repeating = true })
o.bind("ALT + XF86MonBrightnessDown", "Brightness down precise", "eoshell-brightness-display 1%-", { locked = true, repeating = true })

-- Media controls.
o.bind("XF86AudioNext", "Next track", { ipc = "media.next" }, { locked = true })
o.bind("ALT + XF86AudioPlay", "Next track", { ipc = "media.next" }, { locked = true })
o.bind("XF86AudioPause", "Pause", { ipc = "media.playPause" }, { locked = true })
o.bind("XF86AudioPlay", "Play", { ipc = "media.playPause" }, { locked = true })
o.bind("XF86AudioPrev", "Previous track", { ipc = "media.previous" }, { locked = true })
o.bind("ALT + SHIFT + XF86AudioPlay", "Previous track", { ipc = "media.previous" }, { locked = true })
o.bind("XF86Eject", "Eject media", "eject", { locked = true })

o.bind("SHIFT + XF86AudioMute", "Switch audio output", "eoshell-audio-output-switch", { locked = true })
o.bind("SHIFT + XF86AudioPause", "Switch media source", "eoshell-audio-source-switch", { locked = true })
o.bind("SHIFT + XF86AudioPlay", "Switch media source", "eoshell-audio-source-switch", { locked = true })
