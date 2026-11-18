# Extras personales sobre los defaults de Omarchy (portados de .zshrc).
# Se carga desde ~/.bashrc:  [[ -f ~/.config/bash/custom.sh ]] && source ~/.config/bash/custom.sh

# Git (Omarchy ya trae g, gcm, gcam, gcad)
alias gs='git status'
alias gp='git push'
alias gl='git pull'
alias ga='git add'
alias gc='git commit'
alias gd='git diff'
alias lg='lazygit'

# Docker (Omarchy ya trae d)
alias dc='docker compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"'
alias ld='lazydocker'
alias docker-on='sudo systemctl start docker && echo "Docker encendido"'
alias docker-off='sudo systemctl stop docker.service docker.socket && echo "Docker apagado"'
alias docker-status='systemctl is-active docker docker.socket'

# Python / editor
alias py='python3'
alias venv='python3 -m venv .venv && source .venv/bin/activate'
alias activate='source .venv/bin/activate'
alias vi='nvim'
alias vim='nvim'

# Proyectos
export PROJECTS="$HOME/projects"
alias proj='cd "$PROJECTS"'
alias proj.py='cd "$PROJECTS/python"'
alias proj.ts='cd "$PROJECTS/typescript"'
alias proj.me='cd "$PROJECTS/personal"'

# Bases de datos de desarrollo (docker)
export DBS_DIR="$HOME/docker/dbs"
_dbc() { docker compose -f "$DBS_DIR/docker-compose.yml" --env-file "$DBS_DIR/.env" "$@"; }
alias db-up='_dbc up -d && echo "DBs levantadas"'
alias db-down='_dbc down && echo "DBs detenidas"'
alias db-stop='_dbc stop && echo "DBs pausadas (datos conservados)"'
alias db-logs='_dbc logs -f'
alias db-ps='_dbc ps'
alias db-reset='_dbc down -v && echo "DBs eliminadas con volúmenes"'
alias mongoUp='_dbc up -d mongodb mongo-express && echo "MongoDB levantado"'
alias mongoDown='_dbc stop mongodb mongo-express && echo "MongoDB detenido"'
alias mongoShell='docker exec -it dev-mongodb mongosh -u admin -p devpassword --authenticationDatabase admin'
alias mysqlUp='_dbc up -d mysql && echo "MySQL levantado"'
alias mysqlDown='_dbc stop mysql && echo "MySQL detenido"'
alias mysqlShell='docker exec -it dev-mysql mysql -u root -pdevpassword'

# direnv: carga .env al entrar a un proyecto
command -v direnv >/dev/null && eval "$(direnv hook bash)"

# Historial: flechas arriba/abajo buscan por lo ya escrito (sustituye autosuggestions)
if [[ $- == *i* ]]; then
  bind '"\e[A": history-search-backward'
  bind '"\e[B": history-search-forward'
  bind '"\e[1;5A": history-search-backward'
  bind '"\e[1;5B": history-search-forward'
fi
