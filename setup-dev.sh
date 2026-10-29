#!/usr/bin/env bash
# Configura el entorno de desarrollo en Fedora. Pide la clave de sudo una sola vez.
# Es idempotente: se puede ejecutar varias veces sin problema.
set -euo pipefail

FEDORA_VER="$(rpm -E %fedora)"
ZSHRC="$HOME/.zshrc"

log() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

if [[ $EUID -eq 0 ]]; then
  echo "No lo ejecutes como root; usa tu usuario (el script llama a sudo cuando hace falta)." >&2
  exit 1
fi

log "Autenticando sudo"
sudo -v
# Mantiene la sesión de sudo viva mientras corre el script
while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &
KEEPALIVE_PID=$!
trap 'kill $KEEPALIVE_PID 2>/dev/null || true' EXIT

log "Habilitando RPM Fusion (free y nonfree)"
if ! rpm -q rpmfusion-free-release rpmfusion-nonfree-release &>/dev/null; then
  sudo dnf install -y --setopt=retries=5 --setopt=timeout=60 \
    "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VER}.noarch.rpm" \
    "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VER}.noarch.rpm"
else
  echo "Ya habilitado."
fi

log "Instalando codecs multimedia"
if rpm -q ffmpeg-free &>/dev/null; then
  sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
else
  sudo dnf install -y ffmpeg --allowerasing
fi
sudo dnf install -y intel-media-driver

log "Instalando herramientas de build C/C++ y de terminal"
sudo dnf install -y \
  cmake clang ninja-build valgrind pkgconf-pkg-config \
  htop btop eza zoxide httpie direnv

log "Activando yarn (corepack)"
if command -v corepack &>/dev/null; then
  corepack enable
  corepack prepare yarn@stable --activate
else
  echo "corepack no encontrado (¿nvm cargado?); omito yarn." >&2
fi

log "Instalando Insomnia (Flatpak)"
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install --user -y flathub rest.insomnia.Insomnia

log "Configurando zoxide y direnv en $ZSHRC"
add_line() {
  grep -qF -- "$1" "$ZSHRC" 2>/dev/null || echo "$1" >> "$ZSHRC"
}
add_line 'eval "$(zoxide init zsh)"'
add_line 'eval "$(direnv hook zsh)"'

log "Listo. Abre una terminal nueva o ejecuta: source ~/.zshrc"
