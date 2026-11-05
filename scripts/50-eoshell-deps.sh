#!/usr/bin/env bash
# Dependencias para Quickshell y eoshell (mi shell en Quickshell) en Fedora.
# Ejecutar como tu usuario normal (pide sudo solo para dnf):
#   bash ~/dotfiles/scripts/50-eoshell-deps.sh
# Es idempotente: se puede correr varias veces. No toca tu configuración,
# no reemplaza Waybar/swaync y no instala Hyprland (el tuyo está compilado).
set -euo pipefail

if [[ $EUID -eq 0 ]]; then
  echo "No lo corras con sudo: las fuentes se instalan en tu home." >&2
  exit 1
fi

echo "==> 1/3 Paquetes de Fedora (sudo)"
# Solo se instalan los que faltan; --skip-unavailable evita abortar por uno ausente.
sudo dnf install -y --skip-unavailable \
  quickshell qt6-qtmultimedia qt6-qtimageformats \
  foot wtype pamixer ddcutil mpv imv udiskie gum \
  jetbrains-mono-fonts-all fontawesome-fonts-all google-noto-sans-cjk-fonts \
  tesseract zbar qrencode yt-dlp socat \
  kvantum
# Omitidos a propósito: power-profiles-daemon (ya lo cubre tuned-ppd, conflictúan),
# ffmpeg-free (ya tienes ffmpeg completo de RPM Fusion) e ImageMagick (ya instalado).

echo "==> 2/3 JetBrainsMono Nerd Font (usuario, sin sudo)"
font_dir="$HOME/.local/share/fonts/JetBrainsMonoNF"
if fc-list | grep -qi "JetBrainsMono Nerd Font"; then
  echo "    ya instalada, se omite"
else
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  curl -fL --retry 3 -o "$tmp/jbm.tar.xz" \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
  mkdir -p "$font_dir"
  tar -xJf "$tmp/jbm.tar.xz" -C "$font_dir"
  fc-cache -f "$font_dir"
  echo "    instalada en $font_dir"
fi

echo "==> 3/3 Verificación"
missing=0
for c in quickshell foot wtype pamixer mpv grim slurp wl-copy hyprctl hyprpicker hyprsunset; do
  if command -v "$c" >/dev/null; then printf '    ok       %s\n' "$c"
  else printf '    FALTA    %s\n' "$c"; missing=1; fi
done
quickshell --version 2>/dev/null | sed 's/^/    /' || true

cat <<'EOF'

No incluido a propósito (no está en Fedora o ya lo tienes por otra vía):
  - uwsm, gpu-screen-recorder, localsend, nwg-look: no están en los repos.
  - starship y lazygit: los instala 10-user-setup.sh de este repo.
  - Paquetes de Arch (owe, omasnap, etc.) que usaba la referencia: no se necesitan.
EOF
exit $missing
