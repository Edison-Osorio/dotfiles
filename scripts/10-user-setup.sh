#!/usr/bin/env bash
# Entorno de terminal + nvim a nivel de usuario (sin sudo). Correr DESPUÉS de 00-sudo-packages.sh.
# Idempotente: se puede repetir sin romper nada.
set -euo pipefail
DOT="$HOME/dotfiles"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
say() { printf '\n\033[1;35m==> %s\033[0m\n' "$*"; }

link() { # link <origen en repo> <destino>
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then return; fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$BACKUP"; mv "$dst" "$BACKUP/$(basename "$dst")"
    echo "  respaldo: $dst -> $BACKUP/"
  fi
  ln -s "$src" "$dst"; echo "  link: $dst -> $src"
}

say "Fuente JetBrainsMono Nerd Font"
if ! fc-list | grep -qi "JetBrainsMono Nerd"; then
  mkdir -p ~/.local/share/fonts/JetBrainsMonoNF
  curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz \
    | tar -xJ -C ~/.local/share/fonts/JetBrainsMonoNF
  fc-cache -f
else echo "  ya instalada"; fi

say "oh-my-zsh + plugins"
if [ ! -d ~/.oh-my-zsh ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
for p in zsh-autosuggestions zsh-syntax-highlighting; do
  [ -d ~/.oh-my-zsh/custom/plugins/$p ] || git clone --depth 1 https://github.com/zsh-users/$p ~/.oh-my-zsh/custom/plugins/$p
done

say "starship"
command -v starship >/dev/null || { mkdir -p ~/.local/bin; curl -fsSL https://starship.rs/install.sh | sh -s -- --yes --bin-dir ~/.local/bin; }

say "lazygit (si no vino por dnf)"
if ! command -v lazygit >/dev/null; then
  v=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
  mkdir -p ~/.local/bin
  curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${v}/lazygit_${v}_Linux_x86_64.tar.gz" | tar -xz -C ~/.local/bin lazygit
fi

say "Enlaces de configuración (symlinks al repo)"
link "$DOT/config/nvim"            ~/.config/nvim
link "$DOT/config/kitty"           ~/.config/kitty
link "$DOT/config/lazygit"         ~/.config/lazygit
link "$DOT/config/starship.toml"   ~/.config/starship.toml
link "$DOT/home/.zshrc"            ~/.zshrc
link "$DOT/home/.gitignore_global" ~/.gitignore_global
link "$DOT/local/bin/git-identity" ~/.local/bin/git-identity

say "git (sin copiar la identidad del repo)"
git config --global init.defaultBranch main
git config --global core.editor nvim
git config --global core.autocrlf input
git config --global core.excludesfile ~/.gitignore_global
git config --global pull.rebase false
git config --global --replace-all credential.https://github.com.helper ''
git config --global --add         credential.https://github.com.helper '!/usr/bin/gh auth git-credential'

say "nvm + Node LTS"
export NVM_DIR="$HOME/.nvm"
[ -d "$NVM_DIR" ] || curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | PROFILE=/dev/null bash
. "$NVM_DIR/nvm.sh"
nvm install --lts && nvm alias default 'lts/*'
npm install -g typescript prettier eslint neovim

say "pyenv + Python 3.12.7 (tarda unos minutos compilando)"
export PYENV_ROOT="$HOME/.pyenv"
[ -d "$PYENV_ROOT" ] || curl -fsSL https://pyenv.run | bash
export PATH="$PYENV_ROOT/bin:$PATH"; eval "$(pyenv init -)"
pyenv versions --bare | grep -qx 3.12.7 || pyenv install 3.12.7
pyenv global 3.12.7
pip install --upgrade pip pynvim

say "Proyectos"
mkdir -p ~/projects/{python,typescript,personal}

say "Plugins de nvim (headless)"
nvim --headless "+Lazy! sync" +qa 2>&1 | tail -5 || true

say "Listo"
echo "Reabre la terminal (zsh). Falta: git-identity -n 'Tu Nombre' -e 'tu@correo'  y  gh auth login"
echo "Respaldos (si hubo): $BACKUP"
