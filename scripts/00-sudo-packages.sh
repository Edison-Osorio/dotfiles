#!/usr/bin/env bash
# Paquetes del sistema para el entorno de terminal / nvim. Requiere sudo.
# Uso: sudo bash ~/dotfiles/scripts/00-sudo-packages.sh
set -euo pipefail
user="${SUDO_USER:-eosorio}"

dnf install -y \
  zsh neovim python3-neovim kitty tmux \
  git gh direnv curl wget unzip tar \
  fzf ripgrep bat eza fd-find wl-clipboard \
  gcc gcc-c++ make patch tree-sitter-cli \
  zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel \
  openssl-devel tk-devel libffi-devel xz-devel

# lazygit: está en los repos de Fedora recientes; si no, el script de usuario lo baja del release
dnf install -y lazygit || echo "lazygit no está en repos, lo instalará 10-user-setup.sh"

# zsh como shell por defecto
usermod -s /usr/bin/zsh "$user"
echo "OK: paquetes instalados y zsh es ahora el shell de $user (aplica al reabrir sesión)"
