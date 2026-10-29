-- Las sesiones iniciadas desde GDM no cargan ~/.local/bin: sin esto fallan power-menu, wallpaper, zed, claude...
local home_bin = os.getenv("HOME") .. "/.local/bin"
local path = os.getenv("PATH") or "/usr/local/bin:/usr/bin"
if not path:find(home_bin, 1, true) then path = home_bin .. ":" .. path end
hl.env("PATH", path)

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
