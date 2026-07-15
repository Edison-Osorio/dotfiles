#!/usr/bin/env bash
# Setup completo de entorno de programación
# Python | TypeScript | Java | MongoDB | MySQL | Docker
set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; BOLD='\033[1m'; NC='\033[0m'
info()    { echo -e "${CYAN}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
section() { echo -e "\n${BOLD}${YELLOW}━━━ $* ━━━${NC}\n"; }

# ── 1. HERRAMIENTAS BASE ────────────────────────────────────────────────────
section "Herramientas base y shell"

info "Instalando paquetes base..."
sudo dnf install -y \
  zsh git curl wget unzip tar \
  fzf ripgrep bat eza fd-find \
  jq yq \
  gcc gcc-c++ make cmake \
  openssl-devel zlib-devel bzip2-devel \
  libffi-devel readline-devel sqlite-devel \
  xz-devel tk-devel
success "Paquetes base instalados"

# Zsh como shell por defecto
if [ "$SHELL" != "$(which zsh)" ]; then
  info "Cambiando shell por defecto a Zsh..."
  sudo chsh -s "$(which zsh)" "$USER"
  success "Shell cambiado a Zsh (efectivo al próximo login)"
fi

# ── 2. OH MY ZSH ───────────────────────────────────────────────────────────
section "Oh My Zsh"

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  info "Instalando Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  success "Oh My Zsh instalado"
else
  success "Oh My Zsh ya está instalado"
fi

# Plugins útiles
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi
success "Plugins Zsh instalados"

# ── 3. STARSHIP PROMPT ─────────────────────────────────────────────────────
section "Starship prompt"

if ! command -v starship &>/dev/null; then
  info "Instalando Starship..."
  curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
  success "Starship instalado"
else
  success "Starship ya está instalado"
fi

# Config Starship con todos los lenguajes del stack
mkdir -p ~/.config
cat > ~/.config/starship.toml << 'STARSHIP'
"$schema" = 'https://starship.rs/config-schema.json'

format = """
[](color_base)\
$os\
$username\
[](fg:color_base bg:color_blue)\
$directory\
[](fg:color_blue bg:color_aqua)\
$git_branch\
$git_status\
[](fg:color_aqua bg:color_green)\
$python\
$nodejs\
$docker_context\
[](fg:color_green)\
$fill\
$cmd_duration\
$time\
$line_break\
$character"""

palette = 'catppuccin_mocha'

[palettes.catppuccin_mocha]
color_base    = '#1e1e2e'
color_blue    = '#89b4fa'
color_aqua    = '#94e2d5'
color_green   = '#a6e3a1'
color_yellow  = '#f9e2af'
color_red     = '#f38ba8'
color_mauve   = '#cba6f7'
color_text    = '#cdd6f4'
color_subtext = '#a6adc8'

[os]
disabled = false
style = "bg:color_base fg:color_mauve"
[os.symbols]
Linux = "󰌽 "

[username]
show_always = true
style_user  = "bg:color_base fg:color_text"
style_root  = "bg:color_base fg:color_red"
format      = '[ $user ]($style)'

[directory]
style            = "fg:color_base bg:color_blue bold"
format           = "[ 󰉋 $path ]($style)"
truncation_length = 3
truncation_symbol = "…/"

[directory.substitutions]
"Documents" = "󰈙 "
"Downloads" = " "
"Music"     = "󰝚 "
"Pictures"  = " "
"src"       = "󰲋 "

[git_branch]
symbol = ""
style  = "bg:color_aqua fg:color_base"
format = '[ $symbol $branch ]($style)'

[git_status]
style  = "bg:color_aqua fg:color_base"
format = '[$all_status$ahead_behind ]($style)'

[python]
symbol           = " "
style            = "bg:color_green fg:color_base bold"
format           = '[ $symbol$version(\($virtualenv\)) ]($style)'
detect_extensions = ['py']
detect_files     = ['pyproject.toml', 'Pipfile', '.python-version', 'requirements.txt']

[nodejs]
symbol           = " "
style            = "bg:color_green fg:color_base bold"
format           = '[ $symbol$version ]($style)'
detect_extensions = ['js', 'ts', 'mjs', 'cjs']
detect_files     = ['package.json', 'tsconfig.json']

[docker_context]
symbol = "󰡨 "
style  = "bg:color_green fg:color_base bold"
format = '[ $symbol$context ]($style)'
only_with_files = true

[fill]
symbol = " "

[cmd_duration]
min_time = 2000
style    = "fg:color_yellow"
format   = "[ 󱎫 $duration ]($style)"

[time]
disabled  = false
style     = "fg:color_subtext"
format    = "[ 󰥔 $time ]($style)"
time_format = "%H:%M"

[character]
success_symbol = "[❯](bold fg:color_green)"
error_symbol   = "[❯](bold fg:color_red)"
STARSHIP
success "Starship configurado con Python, Node, Java, Docker"

# ── 4. .zshrc ──────────────────────────────────────────────────────────────
section "Configurando .zshrc"

cat > ~/.zshrc << 'ZSHRC'
# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # Starship lo reemplaza
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  docker
  docker-compose
  npm
  python
)
source $ZSH/oh-my-zsh.sh

# Starship
eval "$(starship init zsh)"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
[[ -d $PYENV_ROOT ]] && eval "$(pyenv init -)"
[[ -d $PYENV_ROOT ]] && eval "$(pyenv virtualenv-init -)"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# PATH local
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/usr/local/bin:$PATH"

# Aliases útiles
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first --git'
alias lt='eza --tree --icons --level=2'
alias cat='bat --style=plain'
alias grep='grep --color=auto'

# Git aliases
alias g='git'
alias gs='git status'
alias gp='git push'
alias gl='git pull'
alias ga='git add'
alias gc='git commit'
alias gd='git diff'
alias lg='lazygit'

# Docker aliases
alias d='docker'
alias dc='docker compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"'
alias ld='lazydocker'

# Python aliases
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv .venv && source .venv/bin/activate'
alias activate='source .venv/bin/activate'


# Wayland / Hyprland
export WAYLAND_DISPLAY=wayland-1
export XDG_CURRENT_DESKTOP=Hyprland
export QT_QPA_PLATFORM=wayland
export MOZ_ENABLE_WAYLAND=1

# fzf
[ -f /usr/share/fzf/shell/key-bindings.zsh ] && source /usr/share/fzf/shell/key-bindings.zsh
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc --color=marker:#b5e8e0,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8'
ZSHRC
success ".zshrc configurado"

# ── 5. PYENV ───────────────────────────────────────────────────────────────
section "pyenv (Python)"

if [ ! -d "$HOME/.pyenv" ]; then
  info "Instalando pyenv..."
  curl -fsSL https://pyenv.run | bash
  success "pyenv instalado"
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
  info "Instalando Python 3.12 (estable para producción)..."
  pyenv install 3.12.7
  pyenv global 3.12.7
  success "Python 3.12.7 activo via pyenv"
else
  success "pyenv ya está instalado"
fi

# ── 6. NVM (Node / TypeScript) ─────────────────────────────────────────────
section "nvm + Node.js + TypeScript"

if [ ! -d "$HOME/.nvm" ]; then
  info "Instalando nvm..."
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
  info "Instalando Node.js LTS..."
  nvm install --lts
  nvm use --lts
  nvm alias default 'lts/*'
  npm install -g typescript ts-node nodemon prettier eslint
  success "Node LTS + TypeScript instalados"
else
  success "nvm ya está instalado"
fi

# ── 7. DOCKER CE ───────────────────────────────────────────────────────────
section "Docker CE"

if ! command -v docker &>/dev/null; then
  info "Agregando repositorio Docker..."
  sudo dnf config-manager addrepo \
    --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
  info "Instalando Docker CE..."
  sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  sudo systemctl enable --now docker
  sudo usermod -aG docker "$USER"
  success "Docker CE instalado (necesitas re-login para usar sin sudo)"
else
  success "Docker ya está instalado: $(docker --version)"
fi

# lazydocker
if ! command -v lazydocker &>/dev/null; then
  info "Instalando lazydocker..."
  curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
  success "lazydocker instalado"
fi

# ── 9. LAZYGIT ─────────────────────────────────────────────────────────────
section "lazygit"

if ! command -v lazygit &>/dev/null; then
  info "Instalando lazygit..."
  LAZYGIT_VERSION=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
  curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" \
    | tar -xz -C ~/.local/bin lazygit
  success "lazygit instalado"
else
  success "lazygit ya está instalado"
fi

# ── 10. VSCODE ─────────────────────────────────────────────────────────────
section "Visual Studio Code"

if ! command -v code &>/dev/null; then
  info "Agregando repositorio VSCode..."
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
  sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
  sudo dnf install -y code
  success "VSCode instalado"
else
  success "VSCode ya está instalado"
fi

# Extensiones VSCode
info "Instalando extensiones VSCode..."
EXTENSIONS=(
  "ms-python.python"
  "ms-python.black-formatter"
  "ms-python.pylint"
  "ms-python.debugpy"
  "ms-vscode.vscode-typescript-next"
  "esbenp.prettier-vscode"
  "dbaeumer.vscode-eslint"
  "mongodb.mongodb-vscode"
  "cweijan.vscode-mysql-client2"
  "ms-azuretools.vscode-docker"
  "GitHub.copilot"
  "eamodio.gitlens"
  "usernamehw.errorlens"
  "catppuccin.catppuccin-vsc"
  "catppuccin.catppuccin-vsc-icons"
  "PKief.material-icon-theme"
  "aaron-bond.better-comments"
  "christian-kohler.path-intellisense"
)
for ext in "${EXTENSIONS[@]}"; do
  code --install-extension "$ext" --force 2>/dev/null && echo "  ✓ $ext" || echo "  - $ext (omitida)"
done
success "Extensiones instaladas"

# Settings VSCode con Catppuccin
mkdir -p ~/.config/Code/User
cat > ~/.config/Code/User/settings.json << 'VSCODE'
{
  "workbench.colorTheme": "Catppuccin Mocha",
  "workbench.iconTheme": "catppuccin-mocha",
  "editor.fontFamily": "'JetBrainsMono Nerd Font', 'JetBrains Mono', monospace",
  "editor.fontSize": 13,
  "editor.lineHeight": 1.6,
  "editor.fontLigatures": true,
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.bracketPairColorization.enabled": true,
  "editor.guides.bracketPairs": "active",
  "editor.minimap.enabled": false,
  "editor.renderWhitespace": "boundary",
  "editor.smoothScrolling": true,
  "editor.cursorBlinking": "smooth",
  "editor.cursorSmoothCaretAnimation": "on",
  "editor.wordWrap": "on",
  "editor.inlineSuggest.enabled": true,
  "terminal.integrated.fontFamily": "'JetBrainsMono Nerd Font'",
  "terminal.integrated.fontSize": 13,
  "workbench.startupEditor": "none",
  "workbench.editor.enablePreview": false,
  "explorer.confirmDelete": false,
  "explorer.compactFolders": false,
  "files.autoSave": "onFocusChange",
  "files.trimTrailingWhitespace": true,
  "git.enableSmartCommit": true,
  "git.autofetch": true,
  "[python]": {
    "editor.defaultFormatter": "ms-python.black-formatter",
    "editor.tabSize": 4
  },
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "python.defaultInterpreterPath": "${workspaceFolder}/.venv/bin/python",
  "mongodb.connectionSaving.defaultConnectionSavingLocation": "Workspace"
}
VSCODE
success "VSCode configurado con Catppuccin Mocha"


# ── 12. NEOVIM + LAZYVIM + IA ──────────────────────────────────────────────
section "Neovim + LazyVim + IA (Catppuccin)"

if ! command -v nvim &>/dev/null; then
  info "Instalando Neovim..."
  sudo dnf install -y neovim python3-neovim
  success "Neovim instalado: $(nvim --version | head -1)"
else
  success "Neovim ya instalado: $(nvim --version | head -1)"
fi

info "Instalando dependencias de LazyVim..."
sudo dnf install -y \
  nodejs npm \
  python3-pip \
  wl-clipboard xclip \
  lazygit 2>/dev/null || true

# Neovim providers
npm install -g neovim 2>/dev/null || true
pip3 install --user neovim pynvim 2>/dev/null || true

if [ -d "$HOME/.config/nvim" ]; then
  info "Respaldando config nvim existente -> ~/.config/nvim.bak"
  mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
fi

mkdir -p ~/.config/nvim/{lua/plugins,lua/config}

# ── init.lua ─────────────────────────────────────────────────────────────
cat > ~/.config/nvim/init.lua << 'LUAEOF'
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n" .. out, "ErrorMsg" } }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- LazyVim base + all default plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

    -- Language extras
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.python" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.tailwind" },

    -- Formatting & Linting
    { import = "lazyvim.plugins.extras.formatting.prettier" },
    { import = "lazyvim.plugins.extras.linting.eslint" },

    -- Custom plugins
    { import = "plugins" },
  },
  defaults = { lazy = false, version = false },
  install = { colorscheme = { "catppuccin", "habamax" } },
  checker = { enabled = true, notify = false },
  performance = {
    rtp = {
      disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
    },
  },
})
LUAEOF

# ── config/options.lua ────────────────────────────────────────────────────
cat > ~/.config/nvim/lua/config/options.lua << 'LUAEOF'
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt

-- UI
opt.number         = true
opt.relativenumber = true
opt.cursorline     = true
opt.signcolumn     = "yes"
opt.termguicolors  = true
opt.scrolloff      = 8
opt.sidescrolloff  = 8
opt.splitright     = true
opt.splitbelow     = true
opt.showmode       = false
opt.cmdheight      = 1
opt.pumheight      = 10

-- Indentation — 2 spaces default (overridden per filetype)
opt.tabstop     = 2
opt.shiftwidth  = 2
opt.expandtab   = true
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase  = true
opt.hlsearch   = true

-- Files
opt.undofile   = true
opt.swapfile   = false
opt.backup     = false
opt.updatetime = 200

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }

-- Clipboard: use system clipboard
opt.clipboard = "unnamedplus"

-- Folding (use treesitter)
opt.foldmethod = "expr"
opt.foldexpr   = "nvim_treesitter#foldexpr()"
opt.foldenable = false

-- Python provider: prefer the virtualenv python when available
vim.g.python3_host_prog = vim.fn.exepath("python3")
LUAEOF

# ── config/keymaps.lua ────────────────────────────────────────────────────
cat > ~/.config/nvim/lua/config/keymaps.lua << 'LUAEOF'
local map = vim.keymap.set

-- ── Navigation ──────────────────────────────────────────────────────────────
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Move lines
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Keep cursor centered when jumping
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Better paste (don't lose register)
map("x", "<leader>p", [["_dP]], { desc = "Paste without yank" })

-- ── Diagnostics ──────────────────────────────────────────────────────────────
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- ── LSP (extra shortcuts beyond LazyVim defaults) ────────────────────────────
map("n", "<leader>cr", vim.lsp.buf.rename,      { desc = "Rename symbol" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })

-- ── Quickfix ─────────────────────────────────────────────────────────────────
map("n", "<leader>Q", "<cmd>cclose<cr>", { desc = "Close quickfix" })
map("n", "]q", "<cmd>cnext<cr>",         { desc = "Next quickfix" })
map("n", "[q", "<cmd>cprev<cr>",         { desc = "Prev quickfix" })
LUAEOF

# ── config/autocmds.lua ───────────────────────────────────────────────────
cat > ~/.config/nvim/lua/config/autocmds.lua << 'LUAEOF'
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Django HTML templates
vim.filetype.add({
  pattern = {
    [".*templates/.*%.html"] = "htmldjango",
    [".*templates/.*%.htm"]  = "htmldjango",
    [".*jinja2/.*%.html"]    = "htmldjango",
  },
})

-- Angular HTML templates
vim.filetype.add({
  pattern = {
    [".*%.component%.html"] = "html",
  },
})

-- Python: indent 4 spaces (PEP 8)
autocmd("FileType", {
  group   = augroup("python_indent", { clear = true }),
  pattern = { "python" },
  callback = function()
    vim.opt_local.tabstop    = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab  = true
  end,
})

-- TypeScript/Angular: 2 spaces
autocmd("FileType", {
  group   = augroup("ts_indent", { clear = true }),
  pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact", "html" },
  callback = function()
    vim.opt_local.tabstop    = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab  = true
  end,
})

-- Auto-close quickfix when it's the last window
autocmd("WinEnter", {
  group = augroup("auto_close_qf", { clear = true }),
  callback = function()
    if vim.fn.winnr("$") == 1 and vim.bo.buftype == "quickfix" then
      vim.cmd("quit")
    end
  end,
})

-- Highlight on yank
autocmd("TextYankPost", {
  group    = augroup("highlight_yank", { clear = true }),
  callback = function() vim.highlight.on_yank({ timeout = 150 }) end,
})

-- Update python3_host_prog when venv changes
vim.api.nvim_create_autocmd("User", {
  pattern  = "VenvSelectorActivated",
  callback = function(ev)
    local python = ev.data and ev.data.python_path
    if python then
      vim.g.python3_host_prog = python
    end
  end,
})
LUAEOF

# ── plugins/colorscheme.lua ───────────────────────────────────────────────
cat > ~/.config/nvim/lua/plugins/colorscheme.lua << 'LUAEOF'
return {
  {
    "catppuccin/nvim",
    name     = "catppuccin",
    priority = 1000,
    opts = {
      flavour           = "mocha",
      background        = { light = "latte", dark = "mocha" },
      transparent_background = false,
      show_end_of_buffer     = false,
      term_colors            = true,
      dim_inactive           = { enabled = false },

      styles = {
        comments     = { "italic" },
        conditionals = { "italic" },
        functions    = {},
        keywords     = { "italic" },
        strings      = {},
        variables    = {},
      },

      integrations = {
        cmp                = true,
        gitsigns           = true,
        neo_tree           = true,
        telescope          = { enabled = true, style = "nvchad" },
        treesitter         = true,
        treesitter_context = true,
        mason              = true,
        which_key          = true,
        lsp_trouble        = true,
        noice              = true,
        notify             = true,
        mini               = { enabled = true, indentscope_color = "" },
        indent_blankline   = { enabled = true, scope_color = "lavender", colored_indent_levels = false },
        dashboard          = true,
        bufferline         = true,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors      = { "italic" },
            hints       = { "italic" },
            warnings    = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors      = { "undercurl" },
            hints       = { "undercurl" },
            warnings    = { "undercurl" },
            information = { "undercurl" },
          },
          inlay_hints = { background = true },
        },
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "catppuccin" },
  },
}
LUAEOF

# ── plugins/ai.lua ────────────────────────────────────────────────────────
cat > ~/.config/nvim/lua/plugins/ai.lua << 'LUAEOF'
-- ── A: claude-code.nvim — Claude Code CLI en ventana flotante ────────────────
-- Atajo: <leader>ac  |  no necesita API key, usa el CLI instalado
local M_claude_code = {
  "greggh/claude-code.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>ac", desc = "Claude Code (toggle)" },
    { "<leader>aA", desc = "Claude Code (nueva sesión)" },
  },
  cmd = { "ClaudeCode", "ClaudeCodeContinue" },
  opts = {
    window = {
      position    = "vertical",
      split_ratio = 0.38,
      enter_insert = true,
      hide_numbers = true,
      hide_signcolumn = true,
    },
    keymaps = {
      toggle = {
        normal   = "<leader>ac",
        terminal = "<leader>ac",
      },
      window_navigation = true,
      scrolling = true,
    },
  },
}

-- ── B: avante.nvim — experiencia tipo Cursor (chat + edits inline) ───────────
-- Atajo: <leader>aa  |  REQUIERE: export ANTHROPIC_API_KEY="sk-ant-..."
local M_avante = {
  "yetone/avante.nvim",
  event   = "VeryLazy",
  version = false,
  build   = "make",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = { file_types = { "markdown", "Avante" } },
      ft   = { "markdown", "Avante" },
    },
    {
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts  = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name  = false,
          drag_and_drop         = { insert_mode = true },
          use_absolute_path     = true,
        },
      },
    },
  },
  opts = {
    provider = "claude",
    providers = {
      claude = {
        endpoint   = "https://api.anthropic.com",
        model      = "claude-sonnet-4-6",
        timeout    = 30000,
        extra_request_body = {
          temperature = 0,
          max_tokens  = 8096,
        },
      },
    },
    behaviour = {
      auto_suggestions             = false,
      auto_set_highlight_group     = true,
      auto_set_keymaps             = true,
      auto_apply_diff_after_generation = false,
      support_paste_from_clipboard = true,
    },
    windows = {
      position = "right",
      wrap     = true,
      width    = 35,
      sidebar_header = { align = "center", rounded = true },
    },
    mappings = {
      diff    = { ours = "co", theirs = "ct", both = "cb", next = "]x", prev = "[x" },
      submit  = { normal = "<CR>", insert = "<C-s>" },
      ask     = "<leader>aa",
      edit    = "<leader>ae",
      refresh = "<leader>ar",
    },
    highlights = {
      diff = { current = "DiffText", incoming = "DiffAdd" },
    },
  },
}

-- ── C: terminal flotante con Claude Code CLI ──────────────────────────────────
-- Atajo: <leader>at  |  fallback sin API key
local M_terminal = {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    { "<leader>at", desc = "Claude Code (terminal flotante)" },
    { "<leader>aT", desc = "Terminal flotante" },
  },
  opts = {
    size = function(term)
      if term.direction == "horizontal" then return 18
      elseif term.direction == "vertical" then return math.floor(vim.o.columns * 0.4)
      end
    end,
    open_mapping    = nil,
    hide_numbers    = true,
    shade_terminals = false,
    start_in_insert = true,
    insert_mappings = true,
    persist_size    = true,
    direction       = "float",
    close_on_exit   = true,
    shell           = vim.o.shell,
    float_opts = {
      border   = "rounded",
      width    = math.floor(vim.o.columns * 0.85),
      height   = math.floor(vim.o.lines * 0.80),
      winblend = 3,
    },
    highlights = {
      FloatBorder = { link = "FloatBorder" },
    },
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)
    local Terminal = require("toggleterm.terminal").Terminal

    local claude_term = Terminal:new({
      cmd       = "claude",
      direction = "float",
      hidden    = true,
      on_open = function(t)
        vim.cmd("startinsert!")
        vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { buffer = t.bufnr })
      end,
    })

    local float_term = Terminal:new({
      direction = "float",
      hidden    = true,
      on_open = function(t)
        vim.cmd("startinsert!")
        vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { buffer = t.bufnr })
      end,
    })

    vim.keymap.set("n", "<leader>at", function() claude_term:toggle() end,
      { desc = "Claude Code (terminal flotante)" })
    vim.keymap.set("n", "<leader>aT", function() float_term:toggle() end,
      { desc = "Terminal flotante" })
  end,
}

return { M_claude_code, M_avante, M_terminal }
LUAEOF

# ── plugins/python.lua ────────────────────────────────────────────────────
cat > ~/.config/nvim/lua/plugins/python.lua << 'LUAEOF'
return {
  {
    "linux-cultist/venv-selector.nvim",
    branch       = "regexp",
    dependencies = {
      "neovim/nvim-lspconfig",
      { "nvim-telescope/telescope.nvim", branch = "0.1.x" },
    },
    ft      = "python",
    cmd     = { "VenvSelect", "VenvSelectCached" },
    opts = {
      settings = {
        search = {
          venvs = { command = "fd -HI --no-ignore-vcs -t d 'python' ." },
        },
        options = {
          notify_user_on_venv_activation = true,
          set_environment_variables      = true,
          activate_venv_in_shell         = true,
          parents = 2,
        },
      },
    },
    keys = {
      { "<leader>cv", "<cmd>VenvSelect<cr>",       desc = "Select VirtualEnv",     ft = "python" },
      { "<leader>cV", "<cmd>VenvSelectCached<cr>", desc = "Reuse last VirtualEnv", ft = "python" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode          = "basic",
                autoImportCompletions     = true,
                autoSearchPaths           = true,
                useLibraryCodeForTypes    = true,
                diagnosticMode            = "workspace",
                reportMissingModuleSource = "none",
              },
            },
          },
        },
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode       = "basic",
                autoImportCompletions  = true,
                autoSearchPaths        = true,
                useLibraryCodeForTypes = true,
                diagnosticMode         = "workspace",
              },
            },
          },
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft["htmldjango"] = { "djlint" }
      return opts
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft["htmldjango"] = { "djlint" }
      opts.formatters_by_ft["python"]     = { "ruff_format", "ruff_organize_imports" }
      return opts
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "pyright", "basedpyright", "ruff", "djlint", "black", "isort",
      })
    end,
  },
}
LUAEOF

# ── plugins/typescript.lua ────────────────────────────────────────────────
cat > ~/.config/nvim/lua/plugins/typescript.lua << 'LUAEOF'
local util = require("lspconfig.util")

local function get_typescript_lib(root_dir)
  local local_ts = util.path.join(root_dir, "node_modules", "typescript", "lib")
  if vim.fn.isdirectory(local_ts) == 1 then return local_ts end
  return vim.fn.stdpath("data") .. "/mason/packages/typescript-language-server/node_modules/typescript/lib"
end

local function get_angular_probe(root_dir)
  local local_ng = util.path.join(root_dir, "node_modules")
  if vim.fn.isdirectory(local_ng) == 1 then return local_ng end
  return vim.fn.stdpath("data") .. "/mason/packages/angular-language-server/node_modules"
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ts_ls = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints                        = "literals",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints                = true,
                includeInlayVariableTypeHints                         = false,
                includeInlayPropertyDeclarationTypeHints              = true,
                includeInlayFunctionLikeReturnTypeHints               = true,
                includeInlayEnumMemberValueHints                      = true,
              },
              preferences = { importModuleSpecifier = "relative" },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints          = "literals",
                includeInlayFunctionParameterTypeHints  = true,
                includeInlayVariableTypeHints           = false,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints        = true,
              },
            },
          },
        },
        angularls = {
          root_dir  = util.root_pattern("angular.json", "project.json", ".git"),
          filetypes = { "typescript", "html", "typescriptreact" },
          on_new_config = function(new_config, new_root_dir)
            local ts_probe = get_typescript_lib(new_root_dir)
            local ng_probe = get_angular_probe(new_root_dir)
            new_config.cmd = {
              "ngserver", "--stdio",
              "--tsProbeLocations", ts_probe,
              "--ngProbeLocations",  ng_probe,
            }
          end,
        },
      },
      setup = {
        angularls = function(_, opts)
          require("lspconfig").angularls.setup(opts)
          return true
        end,
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "typescript", "tsx", "javascript", "html", "css", "scss", "json", "graphql",
      })
      return opts
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs({
        "typescript", "typescriptreact", "javascript", "javascriptreact",
        "html", "css", "scss", "less", "json", "jsonc", "yaml", "graphql", "markdown",
      }) do
        opts.formatters_by_ft[ft] = { "prettier" }
      end
      opts.formatters = opts.formatters or {}
      opts.formatters.prettier = {
        require_cwd = false,
        condition = function(_, ctx)
          return vim.fs.find(
            { ".prettierrc", ".prettierrc.js", ".prettierrc.json", "prettier.config.js" },
            { path = ctx.filename, upward = true }
          )[1] ~= nil
        end,
      }
      return opts
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "typescript-language-server", "angular-language-server",
        "eslint-lsp", "prettier", "css-lsp", "html-lsp",
        "json-lsp", "tailwindcss-language-server",
      })
    end,
  },
}
LUAEOF

# ── plugins/indent.lua ────────────────────────────────────────────────────
cat > ~/.config/nvim/lua/plugins/indent.lua << 'LUAEOF'
return {
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = { char = "", smart_indent_cap = true },
      scope = {
        enabled    = true,
        char       = "⋮",
        show_start = true,
        show_end   = true,
        highlight  = "IblScope",
        priority   = 1000,
      },
      exclude = {
        buftypes  = { "terminal", "nofile", "quickfix", "prompt" },
        filetypes = {
          "lspinfo", "packer", "checkhealth", "help", "man",
          "gitcommit", "TelescopePrompt", "TelescopeResults",
          "Trouble", "aerial", "alpha", "dashboard",
        },
      },
    },
  },
}
LUAEOF

# ── plugins/rainbow.lua ───────────────────────────────────────────────────
cat > ~/.config/nvim/lua/plugins/rainbow.lua << 'LUAEOF'
return {
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "VeryLazy",
  },
}
LUAEOF

# ── plugins/which-key-config.lua ──────────────────────────────────────────
cat > ~/.config/nvim/lua/plugins/which-key-config.lua << 'LUAEOF'
return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        {
          "<leader>a", group = "AI / Claude", icon = "󰭹",
          { "<leader>aa", desc = "Avante (chat + edits)",       icon = "💬" },
          { "<leader>ae", desc = "Avante (edit code)",          icon = "✏️"  },
          { "<leader>ac", desc = "Claude Code (toggle)",        icon = "󰚀"  },
          { "<leader>aA", desc = "Claude Code (nueva sesión)",  icon = "🔄" },
          { "<leader>at", desc = "Terminal Claude (flotante)",  icon = "💻" },
          { "<leader>aT", desc = "Terminal flotante",           icon = "⌨️"  },
        },
        {
          "<leader>c", group = "Code", icon = "󰘦",
          { "<leader>cv", desc = "Select VirtualEnv", icon = "🐍" },
          { "<leader>cV", desc = "Reuse VirtualEnv",  icon = "♻️"  },
          { "<leader>cm", desc = "Mason (LSP/tools)", icon = "🔧" },
          { "<leader>cl", desc = "LSP Info",          icon = "ℹ️"  },
          { "<leader>cd", desc = "Line Diagnostics",  icon = "⚠️"  },
          { "<leader>cr", desc = "Rename symbol",     icon = "📝" },
          { "<leader>ca", desc = "Code action",       icon = "⚡" },
        },
      },
    },
  },
}
LUAEOF

# ── plugins/zen.lua ───────────────────────────────────────────────────────
cat > ~/.config/nvim/lua/plugins/zen.lua << 'LUAEOF'
return {
  {
    "folke/twilight.nvim",
    opts = {
      dimming   = { alpha = 0.25, color = { "Normal", "#ffffff" }, term_bg = "#000000", inactive = false },
      context   = 10,
      treesitter = true,
      expand    = { "function", "method", "table", "if_statement", "for_statement", "while_statement" },
    },
    cmd  = "Twilight",
    keys = { { "<leader>zt", "<cmd>Twilight<cr>", desc = "Twilight (atenuar código)" } },
  },
  {
    "folke/zen-mode.nvim",
    dependencies = { "folke/twilight.nvim" },
    opts = {
      window = {
        backdrop = 0.95,
        width    = 120,
        height   = 1.0,
        options  = {
          signcolumn    = "no",
          number        = true,
          relativenumber = false,
          cursorline    = false,
          foldcolumn    = "0",
          list          = false,
        },
      },
      plugins = {
        options  = { enabled = true, ruler = false, showcmd = false, laststatus = 0 },
        twilight = { enabled = false },
        gitsigns = { enabled = false },
        kitty    = { enabled = false },
      },
      on_open  = function() vim.cmd("IBLToggle") end,
      on_close = function() vim.cmd("IBLToggle") end,
    },
    cmd  = "ZenMode",
    keys = { { "<leader>zz", "<cmd>ZenMode<cr>", desc = "Zen Mode (UI limpia)" } },
  },
  {
    "folke/zen-mode.nvim",
    init = function()
      vim.api.nvim_create_user_command("ZenFull", function()
        vim.cmd("ZenMode")
        vim.cmd("Twilight")
      end, {})
    end,
    keys = {
      {
        "<leader>za",
        function() vim.cmd("ZenMode"); vim.cmd("Twilight") end,
        desc = "Zen + Twilight (full focus)",
      },
    },
  },
}
LUAEOF

# Alias nvim en .zshrc
if ! grep -q "alias vi=" ~/.zshrc 2>/dev/null; then
  printf '\n# Neovim\nalias vi="nvim"\nalias vim="nvim"\n' >> ~/.zshrc
fi

success "Neovim configurado: LazyVim + Catppuccin + Python/Django + TypeScript/Angular + IA (avante + claude-code + toggleterm)"
info "Primera apertura de nvim: LazyVim instalará todos los plugins automáticamente"
info "IA con Claude: export ANTHROPIC_API_KEY=sk-ant-... en ~/.zshrc y usa <leader>aa (avante)"
info "IA con Claude Code CLI: instala 'npm install -g @anthropic-ai/claude-code' y usa <leader>ac"


# ── 13. KITTY ──────────────────────────────────────────────────────────────
section "Kitty terminal"

if ! command -v kitty &>/dev/null; then
  info "Instalando Kitty..."
  sudo dnf install -y kitty
  success "Kitty instalado: $(kitty --version)"
else
  success "Kitty ya instalado: $(kitty --version)"
fi

mkdir -p ~/.config/kitty

# Respaldar config anterior si existe y tiene contenido
if [ -s "$HOME/.config/kitty/kitty.conf" ]; then
  cp "$HOME/.config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf.bak"
  info "Config anterior respaldada en kitty.conf.bak"
fi

cat > ~/.config/kitty/kitty.conf << 'KITTY'
# ══════════════════════════════════════════════════════════════════════════════
#  Kitty — Entorno de desarrollo
#  Tema: Catppuccin Mocha  |  Stack: Python · TypeScript · Docker · Neovim
# ══════════════════════════════════════════════════════════════════════════════

# ── Font ──────────────────────────────────────────────────────────────────────
font_family      JetBrainsMono Nerd Font
bold_font        JetBrainsMono Nerd Font Bold
italic_font      JetBrainsMono Nerd Font Italic
bold_italic_font JetBrainsMono Nerd Font Bold Italic
font_size        13.0
disable_ligatures never
symbol_map U+E000-U+E00A,U+EA60-U+EBEB,U+E0A0-U+E0C8,U+E0CA,U+E0CC-U+E0D7 Symbols Nerd Font Mono

# ── Rendimiento ───────────────────────────────────────────────────────────────
repaint_delay   8
input_delay     1
sync_to_monitor yes

# ── Cursor ────────────────────────────────────────────────────────────────────
cursor_shape              beam
cursor_beam_thickness     1.8
cursor_blink_interval     0.6
cursor_stop_blinking_after 10.0

# ── Ventana ───────────────────────────────────────────────────────────────────
background_opacity         0.92
dynamic_background_opacity yes
background_blur            20
window_padding_width       10
placement_strategy         center
hide_window_decorations    yes
confirm_os_window_close    0
resize_debounce_time       0.02
draw_minimal_borders       yes
window_border_width        1.5pt
active_border_color        #CBA6F7
inactive_border_color      #313244

# ── Scrollback ────────────────────────────────────────────────────────────────
scrollback_lines              10000
scrollback_pager              less --chop-long-lines --RAW-CONTROL-CHARS +INPUT_LINE_NUMBER
scrollback_pager_history_size 10

# ── Mouse ─────────────────────────────────────────────────────────────────────
mouse_hide_wait     2.0
copy_on_select      no
strip_trailing_spaces smart
open_url_with       default

# ── URL hints ─────────────────────────────────────────────────────────────────
url_color   #89B4FA
url_style   curly
detect_urls yes

# ── Bell ──────────────────────────────────────────────────────────────────────
enable_audio_bell    no
visual_bell_duration 0.0

# ── Layouts de trabajo ────────────────────────────────────────────────────────
enabled_layouts tall,stack,fat,grid

# ── Tab bar ───────────────────────────────────────────────────────────────────
tab_bar_edge          bottom
tab_bar_style         powerline
tab_powerline_style   round
tab_bar_min_tabs      1
tab_title_template    " {fmt.fg.tab}{title[:20]}{bell_symbol} "
active_tab_font_style bold
tab_bar_background    #11111B
tab_bar_margin_color  #11111B

# ── Shell integration ─────────────────────────────────────────────────────────
shell_integration     enabled
allow_cloning         ask
clone_source_strategies venv,conda,env_var,path

# ── Remote control (integración nvim / scripts) ───────────────────────────────
allow_remote_control  yes
listen_on             unix:/tmp/kitty-{kitty_pid}

# ── Terminal ID ───────────────────────────────────────────────────────────────
term xterm-kitty

# ── Wayland ───────────────────────────────────────────────────────────────────
linux_display_server wayland

# ══════════════════════════════════════════════════════════════════════════════
#  KEYBINDINGS
# ══════════════════════════════════════════════════════════════════════════════

# ── Splits ────────────────────────────────────────────────────────────────────
map ctrl+shift+d     launch --location=hsplit --cwd=current
map ctrl+shift+s     launch --location=vsplit --cwd=current
map ctrl+shift+z     toggle_layout stack

# Navegación vim-style entre paneles
map ctrl+h           neighboring_window left
map ctrl+j           neighboring_window bottom
map ctrl+k           neighboring_window top
map ctrl+l           neighboring_window right

# Mover paneles
map ctrl+shift+h     move_window left
map ctrl+shift+j     move_window bottom
map ctrl+shift+k     move_window top
map ctrl+shift+l     move_window right

# Redimensionar paneles
map alt+left         resize_window narrower 3
map alt+right        resize_window wider 3
map alt+up           resize_window taller 3
map alt+down         resize_window shorter 3
map alt+r            resize_window reset

# ── Tabs ──────────────────────────────────────────────────────────────────────
map ctrl+t           new_tab_with_cwd
map ctrl+w           close_tab
map ctrl+1           goto_tab 1
map ctrl+2           goto_tab 2
map ctrl+3           goto_tab 3
map ctrl+4           goto_tab 4
map ctrl+5           goto_tab 5
map ctrl+tab         next_tab
map ctrl+shift+tab   previous_tab
map ctrl+shift+,     move_tab_backward
map ctrl+shift+.     move_tab_forward
map ctrl+shift+alt+t set_tab_title

# ── Fuente ────────────────────────────────────────────────────────────────────
map ctrl+equal       change_font_size all +1.0
map ctrl+minus       change_font_size all -1.0
map ctrl+0           change_font_size all 0

# ── Copiar / Pegar ────────────────────────────────────────────────────────────
map ctrl+shift+c     copy_to_clipboard
map ctrl+shift+v     paste_from_clipboard

# ── Scrollback ────────────────────────────────────────────────────────────────
map ctrl+shift+up    scroll_line_up
map ctrl+shift+down  scroll_line_down
map ctrl+shift+home  scroll_home
map ctrl+shift+end   scroll_end

# ── Hints (selección inteligente) ─────────────────────────────────────────────
map ctrl+shift+p>f   kitten hints --type path --program @
map ctrl+shift+p>l   kitten hints --type line --program @
map ctrl+shift+p>w   kitten hints --type word --program @
map ctrl+shift+p>u   kitten hints --type url

# ── Búsqueda con fzf en scrollback ───────────────────────────────────────────
map ctrl+shift+f     launch --type=overlay --stdin-source=@screen_scrollback fzf --no-sort --no-mouse --exact -i

# ── Config ────────────────────────────────────────────────────────────────────
map ctrl+shift+F5    load_config_file
map ctrl+shift+F2    edit_config_file

# Opacidad en caliente
map ctrl+shift+a>m   set_background_opacity +0.05
map ctrl+shift+a>l   set_background_opacity -0.05
map ctrl+shift+a>1   set_background_opacity 1
map ctrl+shift+a>d   set_background_opacity default

# ══════════════════════════════════════════════════════════════════════════════
#  COLORES — Catppuccin Mocha
# ══════════════════════════════════════════════════════════════════════════════
foreground           #CDD6F4
background           #1E1E2E
selection_foreground #1E1E2E
selection_background #CDD6F4

cursor               #F5E0DC
cursor_text_color    #1E1E2E

active_tab_foreground   #11111B
active_tab_background   #CBA6F7
inactive_tab_foreground #CDD6F4
inactive_tab_background #181825

color0   #45475A
color8   #585B70
color1   #F38BA8
color9   #F38BA8
color2   #A6E3A1
color10  #A6E3A1
color3   #F9E2AF
color11  #F9E2AF
color4   #89B4FA
color12  #89B4FA
color5   #CBA6F7
color13  #CBA6F7
color6   #94E2D5
color14  #94E2D5
color7   #BAC2DE
color15  #A6ADC8

mark1_foreground #1E1E2E
mark1_background #CBA6F7
mark2_foreground #1E1E2E
mark2_background #94E2D5
mark3_foreground #1E1E2E
mark3_background #F9E2AF
KITTY
success "Kitty configurado con Catppuccin Mocha + splits + navegación vim-style"

# ── RESUMEN FINAL ───────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  Entorno de programación instalado               ${NC}"
echo -e "${GREEN}${BOLD}══════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}Herramientas:${NC}"
command -v zsh       &>/dev/null && echo "  ✓ Zsh + Oh My Zsh + Starship"
command -v code      &>/dev/null && echo "  ✓ VSCode con Catppuccin Mocha"
command -v docker    &>/dev/null && echo "  ✓ Docker CE: $(docker --version 2>/dev/null | cut -d' ' -f3 | tr -d ',')"
command -v lazygit   &>/dev/null && echo "  ✓ lazygit"
command -v lazydocker &>/dev/null && echo "  ✓ lazydocker"
command -v starship  &>/dev/null && echo "  ✓ Starship prompt"
command -v fzf       &>/dev/null && echo "  ✓ fzf + ripgrep + bat + eza"
command -v nvim      &>/dev/null && echo "  ✓ Neovim + LazyVim + LSP + IA (CodeCompanion + Copilot + Supermaven)"
command -v kitty     &>/dev/null && echo "  ✓ Kitty + Catppuccin Mocha + splits + vim-navigation"
echo ""
echo -e "${YELLOW}Pasos manuales pendientes:${NC}"
echo "  1. Re-login para activar Zsh y Docker sin sudo"
echo "  2. En Zsh: pyenv install 3.12.7 && pyenv global 3.12.7"
echo "  3. Abrir nvim → lazy.nvim instala plugins automáticamente"
echo "  4. En nvim: :Copilot auth   (para activar GitHub Copilot)"
echo "  5. En ~/.zshrc: export ANTHROPIC_API_KEY=<tu_key>  (para CodeCompanion con Claude)"
echo ""
echo -e "${CYAN}Aliases listos:${NC}"
echo "  lg  → lazygit     ld → lazydocker"
echo "  ll  → eza         cat → bat"
echo "  dps → docker ps   venv → crear virtualenv"
