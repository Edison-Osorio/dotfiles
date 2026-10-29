#!/usr/bin/env bash
# Instala Hyprland como SEGUNDA sesión (GNOME no se toca) y deja la config lista.
# Uso (como usuario normal, pide sudo una vez):  bash ~/dotfiles/scripts/30-hyprland.sh
set -euo pipefail

[ "$(id -u)" -ne 0 ] || { echo "Córrelo como usuario normal, no con sudo."; exit 1; }
DOT="$HOME/dotfiles/hyprland"
BACKUP="$HOME/.dotfiles-backup/hyprland-$(date +%Y%m%d-%H%M%S)"
say() { printf '\n\033[1;35m==> %s\033[0m\n' "$*"; }

say "1/3 Paquetes (COPR sdegler/hyprland limitado a hypr*, el resto de repos de Fedora)"
sudo dnf install -y dnf-plugins-core
sudo dnf copr enable -y sdegler/hyprland
repo=$(ls /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:sdegler:hyprland.repo)
if ! grep -q '^includepkgs=' "$repo"; then
  sudo sed -i '/^\[.*\]$/a includepkgs=hypr* aquamarine xdg-desktop-portal-hyprland' "$repo"
fi
sudo dnf install -y --refresh \
  hyprland hyprlock hypridle hyprpaper hyprpolkitagent hyprpicker \
  hyprsunset hyprland-guiutils xdg-desktop-portal-hyprland
sudo dnf install -y \
  waybar rofi SwayNotificationCenter wlogout \
  cava fastfetch btop \
  grim slurp wl-clipboard cliphist \
  brightnessctl playerctl pavucontrol blueman network-manager-applet \
  xdg-desktop-portal-gtk NetworkManager-tui wiremix swappy

say "2/3 Enlaces de configuración (symlinks a ~/dotfiles/hyprland)"
link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then return; fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$BACKUP"; mv "$dst" "$BACKUP/$(basename "$dst")"; echo "  respaldo: $dst -> $BACKUP/"
  fi
  ln -s "$src" "$dst"; echo "  link: $dst -> $src"
}
link "$DOT/hypr"   ~/.config/hypr
link "$DOT/waybar" ~/.config/waybar
link "$DOT/rofi"   ~/.config/rofi
link "$DOT/bin/wallpaper" ~/.local/bin/wallpaper
link "$DOT/bin/power-menu" ~/.local/bin/power-menu
link "$DOT/bin/launch-tui" ~/.local/bin/launch-tui
link "$DOT/bin/clipboard-menu" ~/.local/bin/clipboard-menu
mkdir -p ~/.config/systemd/user
link "$DOT/systemd/hyprland-session.target" ~/.config/systemd/user/hyprland-session.target
link "$DOT/bin/screenshot" ~/.local/bin/screenshot
link "$DOT/bin/tui-close-outside" ~/.local/bin/tui-close-outside
link "$DOT/bin/monitor-layout" ~/.local/bin/monitor-layout
link "$DOT/bin/idle-settings" ~/.local/bin/idle-settings
link "$DOT/bin/battery-limit" ~/.local/bin/battery-limit
link "$DOT/swaync" ~/.config/swaync
for d in gtk-3.0 gtk-4.0; do
  for f in settings.ini gtk.css; do link "$DOT/gtk/$d/$f" ~/.config/$d/$f; done
done

say "3/3 Verificación"
rpm -q hyprland hyprlock hypridle waybar kitty
echo "Sesiones disponibles: $(ls /usr/share/wayland-sessions/ | tr '\n' ' ')"
if command -v Hyprland >/dev/null; then
  echo "--- Hyprland --verify-config"
  Hyprland --verify-config 2>&1 | tail -15 || true
fi

cat <<MSG

Listo. Para probarlo:
  1. Cierra sesión de GNOME.
  2. En la pantalla de login, pulsa el engranaje (abajo a la derecha) y elige "Hyprland".
  3. Atajos básicos: SUPER+Enter terminal · SUPER+Espacio lanzador · SUPER+Q cerrar
     SUPER+1..9 espacios · SUPER+CTRL+L bloquear · SUPER+SHIFT+E salir.
Si algo falla, vuelves a GNOME desde el mismo engranaje.
MSG
