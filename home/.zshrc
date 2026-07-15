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

# Neovim
alias vi="nvim"
alias vim="nvim"

# Proyectos
export PROJECTS="$HOME/projects"
alias proj='cd "$PROJECTS"'
alias proj.py='cd "$PROJECTS/python"'
alias proj.ts='cd "$PROJECTS/typescript"'
alias proj.me='cd "$PROJECTS/personal"'

# Docker — bases de datos de desarrollo
export DBS_DIR="$HOME/docker/dbs"

# Todas las DBs
alias db-up='docker compose -f "$DBS_DIR/docker-compose.yml" --env-file "$DBS_DIR/.env" up -d && echo "DBs levantadas"'
alias db-down='docker compose -f "$DBS_DIR/docker-compose.yml" down && echo "DBs detenidas"'
alias db-stop='docker compose -f "$DBS_DIR/docker-compose.yml" stop && echo "DBs pausadas (datos conservados)"'
alias db-logs='docker compose -f "$DBS_DIR/docker-compose.yml" logs -f'
alias db-ps='docker compose -f "$DBS_DIR/docker-compose.yml" ps'
alias db-reset='docker compose -f "$DBS_DIR/docker-compose.yml" down -v && echo "DBs eliminadas con volúmenes"'

# MongoDB
alias mongoUp='docker compose -f "$DBS_DIR/docker-compose.yml" --env-file "$DBS_DIR/.env" up -d mongodb mongo-express && echo "MongoDB levantado"'
alias mongoDown='docker compose -f "$DBS_DIR/docker-compose.yml" stop mongodb mongo-express && echo "MongoDB detenido"'
alias mongoShell='docker exec -it dev-mongodb mongosh -u admin -p devpassword --authenticationDatabase admin'

# MySQL
alias mysqlUp='docker compose -f "$DBS_DIR/docker-compose.yml" --env-file "$DBS_DIR/.env" up -d mysql && echo "MySQL levantado"'
alias mysqlDown='docker compose -f "$DBS_DIR/docker-compose.yml" stop mysql && echo "MySQL detenido"'
alias mysqlShell='docker exec -it dev-mysql mysql -u root -pdevpassword'

# direnv — carga .env automáticamente al entrar a un proyecto
eval "$(direnv hook zsh)"
