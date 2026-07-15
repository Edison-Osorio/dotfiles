#!/usr/bin/env bash
# Compila Hyprland desde código fuente en Fedora 44
# aquamarine v0.9.5 + Hyprland v0.51.1
set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${CYAN}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
die()     { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

SRC_DIR="$HOME/.local/src/hyprland-build"
mkdir -p "$SRC_DIR"

# ── PASO A: Paquetes del COPR que SÍ funcionan ─────────────────────────────
info "Instalando ecosistema Hyprland desde COPR (hyprutils, hyprlang, etc.)..."
sudo dnf install -y \
  hyprutils hyprutils-devel \
  hyprlang hyprlang-devel \
  hyprcursor hyprcursor-devel \
  hyprgraphics hyprgraphics-devel \
  hyprland-protocols-devel \
  hyprwayland-scanner \
  xdg-desktop-portal-hyprland
success "Ecosistema instalado"

# ── PASO B: Dependencias de compilación ────────────────────────────────────
info "Instalando dependencias de compilación..."
sudo dnf install -y \
  cmake ninja-build gcc-c++ pkg-config git \
  wayland-devel wayland-protocols-devel \
  libdrm-devel mesa-libgbm-devel mesa-libEGL-devel \
  libinput-devel libdisplay-info-devel \
  pixman-devel libxkbcommon-devel \
  libX11-devel libXcursor-devel \
  xcb-util-wm-devel xcb-util-renderutil-devel libxcb-devel xcb-util-keysyms-devel \
  pango-devel cairo-devel \
  tomlplusplus-devel \
  spdlog-devel \
  glslang glslang-devel \
  hwdata-devel \
  libseat-devel \
  xorg-x11-server-Xwayland \
  glm-devel \
  re2-devel \
  libudev-devel systemd-devel \
  libuuid-devel \
  jq
success "Dependencias de compilación listas"

# ── PASO C: Compilar aquamarine ─────────────────────────────────────────────
info "Clonando aquamarine v0.9.5..."
rm -rf "$SRC_DIR/aquamarine"
git clone --depth 1 --branch v0.9.5 https://github.com/hyprwm/aquamarine "$SRC_DIR/aquamarine"

info "Compilando aquamarine (esto toma ~1-2 minutos)..."
cd "$SRC_DIR/aquamarine"
cmake -B build -G Ninja \
  -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DCMAKE_BUILD_TYPE=Release
ninja -C build -j"$(nproc)"
sudo ninja -C build install
sudo ldconfig
success "aquamarine instalado en /usr/local"

# ── PASO D: Compilar Hyprland ───────────────────────────────────────────────
info "Clonando Hyprland v0.51.1..."
rm -rf "$SRC_DIR/Hyprland"
git clone --depth 1 --branch v0.51.1 \
  --recurse-submodules https://github.com/hyprwm/Hyprland "$SRC_DIR/Hyprland"

info "Compilando Hyprland (esto toma ~3-5 minutos)..."
cd "$SRC_DIR/Hyprland"
cmake -B build -G Ninja \
  -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH="/usr/local;/usr"
ninja -C build -j"$(nproc)"
sudo ninja -C build install
sudo ldconfig
success "Hyprland instalado en /usr/local"

# ── PASO E: Resto del stack desde repos oficiales ──────────────────────────
info "Instalando waybar, kitty, wofi, dunst, swww y herramientas..."
sudo dnf install -y \
  waybar \
  kitty \
  wofi \
  dunst \
  swww \
  grim \
  slurp \
  playerctl \
  brightnessctl \
  blueman \
  pavucontrol \
  lxqt-policykit \
  qt5-qtwayland \
  nwg-look
success "Stack completo instalado"

# ── PASO F: Sesión GDM ─────────────────────────────────────────────────────
info "Registrando sesión Hyprland en GDM..."
sudo tee /usr/share/wayland-sessions/hyprland.desktop > /dev/null << 'EOF'
[Desktop Entry]
Name=Hyprland
Comment=Hyprland Wayland compositor
Exec=/usr/local/bin/Hyprland
Type=Application
DesktopNames=Hyprland
EOF
success "Sesión registrada en GDM"

# ── VERIFICACIÓN FINAL ──────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}  Hyprland instalado correctamente         ${NC}"
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo ""
echo "  Versión: $(Hyprland --version 2>/dev/null || echo 'ver abajo')"
which Hyprland && echo "  Binario: $(which Hyprland)"
echo ""
echo -e "${YELLOW}Próximo paso:${NC}"
echo "  1. Cierra sesión"
echo "  2. En GDM, haz clic en el engranaje ⚙"
echo "  3. Selecciona 'Hyprland'"
echo "  4. Inicia sesión"
echo ""
echo -e "${CYAN}Atajos de teclado:${NC}"
echo "  Super+Return  → Terminal (Kitty)"
echo "  Super+D       → Lanzador (Wofi)"
echo "  Super+Q       → Cerrar ventana"
echo "  Super+1..9    → Cambiar workspace"
echo "  Print         → Captura pantalla"
