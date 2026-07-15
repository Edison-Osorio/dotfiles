#!/usr/bin/env bash
# Repositorios y herramientas de desarrollo — Fedora
# Instala: RPM Fusion, GitHub CLI, Flathub, Bruno, DBeaver, gh, direnv, httpie
set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; BOLD='\033[1m'; NC='\033[0m'
info()    { echo -e "${CYAN}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
section() { echo -e "\n${BOLD}${YELLOW}━━━ $* ━━━${NC}\n"; }

FEDORA_VER=$(rpm -E %fedora)

# ── 1. RPM FUSION (free + nonfree) ──────────────────────────────────────────
section "RPM Fusion"

if ! rpm -q rpmfusion-free-release &>/dev/null; then
  info "Instalando RPM Fusion Free..."
  sudo dnf install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VER}.noarch.rpm"
  success "RPM Fusion Free activado"
else
  success "RPM Fusion Free ya está activo"
fi

if ! rpm -q rpmfusion-nonfree-release &>/dev/null; then
  info "Instalando RPM Fusion Non-Free..."
  sudo dnf install -y \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VER}.noarch.rpm"
  success "RPM Fusion Non-Free activado"
else
  success "RPM Fusion Non-Free ya está activo"
fi

# Multimedia completo (ffmpeg, codecs)
info "Instalando ffmpeg y codecs multimedia..."
sudo dnf install -y ffmpeg ffmpeg-libs 2>/dev/null || true
success "ffmpeg listo"

# ── 2. GITHUB CLI ────────────────────────────────────────────────────────────
section "GitHub CLI (gh)"

if ! command -v gh &>/dev/null; then
  info "Agregando repo GitHub CLI..."
  sudo dnf config-manager addrepo \
    --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo 2>/dev/null || \
  sudo tee /etc/yum.repos.d/gh-cli.repo > /dev/null << 'EOF'
[gh-cli]
name=packages for the GitHub CLI
baseurl=https://cli.github.com/packages/rpm
enabled=1
gpgcheck=1
gpgkey=https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x23F3D4EA75716059
EOF
  sudo dnf install -y gh
  success "GitHub CLI instalado: $(gh --version | head -1)"
else
  success "GitHub CLI ya instalado: $(gh --version | head -1)"
fi

# ── 3. HERRAMIENTAS DNF ──────────────────────────────────────────────────────
section "direnv + httpie"

info "Instalando direnv y httpie..."
sudo dnf install -y direnv httpie
success "direnv $(direnv --version) y httpie instalados"

# ── 4. FLATHUB ───────────────────────────────────────────────────────────────
section "Flathub"

if ! flatpak remotes | grep -q "flathub"; then
  info "Agregando Flathub..."
  sudo flatpak remote-add --if-not-exists flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo
  success "Flathub activado"
else
  success "Flathub ya está activo"
fi

# ── 5. BRUNO (cliente REST/API) ───────────────────────────────────────────────
section "Bruno — cliente REST"

if ! flatpak list | grep -q "com.usebruno.Bruno"; then
  info "Instalando Bruno desde Flathub..."
  flatpak install -y flathub com.usebruno.Bruno
  success "Bruno instalado"
else
  success "Bruno ya está instalado"
fi

# ── 6. DBEAVER (GUI para DBs en Docker) ──────────────────────────────────────
section "DBeaver Community — GUI de bases de datos"

if ! flatpak list | grep -q "io.dbeaver.DBeaverCommunity"; then
  info "Instalando DBeaver desde Flathub..."
  flatpak install -y flathub io.dbeaver.DBeaverCommunity
  success "DBeaver instalado"
else
  success "DBeaver ya está instalado"
fi

# ── 7. DIRENV — hook en .zshrc ───────────────────────────────────────────────
section "Configurando direnv en zsh"

if ! grep -q "direnv hook" ~/.zshrc 2>/dev/null; then
  printf '\n# direnv — carga .env automáticamente al entrar a un proyecto\neval "$(direnv hook zsh)"\n' >> ~/.zshrc
  success "direnv hook agregado a .zshrc"
else
  success "direnv hook ya está en .zshrc"
fi

# ── RESUMEN ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  Repos y herramientas instaladas                 ${NC}"
echo -e "${GREEN}${BOLD}══════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}Repos activos:${NC}"
rpm -q rpmfusion-free-release    &>/dev/null && echo "  ✓ RPM Fusion Free"
rpm -q rpmfusion-nonfree-release &>/dev/null && echo "  ✓ RPM Fusion Non-Free"
flatpak remotes | grep -q flathub && echo "  ✓ Flathub"
echo ""
echo -e "${CYAN}Herramientas:${NC}"
command -v gh        &>/dev/null && echo "  ✓ GitHub CLI — $(gh --version | head -1)"
command -v direnv    &>/dev/null && echo "  ✓ direnv $(direnv --version)"
command -v http      &>/dev/null && echo "  ✓ httpie $(http --version)"
command -v ffmpeg    &>/dev/null && echo "  ✓ ffmpeg"
flatpak list 2>/dev/null | grep -q "Bruno"   && echo "  ✓ Bruno (cliente REST)"
flatpak list 2>/dev/null | grep -q "DBeaver" && echo "  ✓ DBeaver (GUI bases de datos)"
echo ""
echo -e "${YELLOW}Pasos siguientes:${NC}"
echo "  1. Reinicia la terminal para activar direnv"
echo "  2. gh auth login  →  autenticar GitHub CLI"
echo "  3. En cada proyecto: echo 'layout python' > .envrc && direnv allow"
echo "  4. Configurar SSH: ssh-keygen -t ed25519 -C edisonosorio96@gmail.com"
