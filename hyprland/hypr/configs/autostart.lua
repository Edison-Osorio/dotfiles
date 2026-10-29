hl.on("hyprland.start", function()
  -- Entorno para D-Bus/systemd (portales, apps)
  -- y activar graphical-session.target (GDM no lo hace): sin él no arranca xdg-desktop-portal
  hl.exec_cmd("sh -c 'dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE; systemctl --user start hyprland-session.target'")

  -- Llavero: conectar con el daemon que PAM ya desbloqueó al iniciar sesión (como hace GNOME).
  -- Va ANTES que las apps que piden secretos; si no, systemd arranca otro daemon, bloqueado.
  hl.exec_cmd([[sh -c 'eval "$(gnome-keyring-daemon --start --components=secrets,pkcs11,ssh)"; \
    dbus-update-activation-environment --systemd GNOME_KEYRING_CONTROL SSH_AUTH_SOCK; \
    wait']])

  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("swaync")
  hl.exec_cmd("waybar")
  hl.exec_cmd("hypridle")
  hl.exec_cmd("battery-limit apply")
  hl.exec_cmd("bluetooth-power apply")
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("wl-paste --watch cliphist store")
end)
