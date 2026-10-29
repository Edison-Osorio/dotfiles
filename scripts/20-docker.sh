#!/usr/bin/env bash
# Docker Engine (moby-engine de Fedora, sin Docker Desktop). Requiere sudo.
# Queda APAGADO y sin arranque automático: se prende a mano con `docker-on`.
# Uso: sudo bash ~/dotfiles/scripts/20-docker.sh
set -euo pipefail
user="${SUDO_USER:-eosorio}"

dnf install -y moby-engine docker-compose docker-buildx

# Sin arranque al boot ni activación por socket (si no, el primer `docker ps` lo prendería)
systemctl disable docker.service docker.socket 2>/dev/null || true
systemctl stop docker.service docker.socket 2>/dev/null || true

usermod -aG docker "$user"
echo "OK: docker instalado, apagado y deshabilitado. $user agregado al grupo docker (cierra sesión y vuelve a entrar)."
