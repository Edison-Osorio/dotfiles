#!/usr/bin/env bash
# Retoma la instalación desde el paso de Hyprland
# (aquamarine ya está instalado correctamente)
set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${CYAN}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
die()     { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

SRC_DIR="$HOME/.local/src/hyprland-build"

# ── PASO B2: Todas las dependencias de compilación de Hyprland ─────────────
info "Instalando dependencias de compilación (completas)..."
sudo dnf install -y \
  libuuid-devel \
  xcb-util-errors-devel \
  xcb-util-wm-devel \
  xcb-util-renderutil-devel \
  xcb-util-keysyms-devel \
  libxcb-devel \
  libXcursor-devel \
  libX11-devel \
  xorg-x11-server-Xwayland \
  pango-devel \
  cairo-devel \
  re2-devel \
  tomlplusplus-devel \
  spdlog-devel \
  glslang glslang-devel \
  glm-devel \
  libseat-devel \
  libudev-devel systemd-devel \
  hwdata-devel \
  libdisplay-info-devel \
  libinput-devel \
  libdrm-devel \
  mesa-libgbm-devel mesa-libEGL-devel \
  pixman-devel \
  libxkbcommon-devel \
  wayland-devel wayland-protocols-devel \
  cmake ninja-build gcc-c++ pkg-config git
success "Dependencias instaladas"

# ── PASO D: Compilar Hyprland ───────────────────────────────────────────────
HYPR_DIR="$SRC_DIR/Hyprland"

if [ ! -d "$HYPR_DIR" ]; then
    info "Clonando Hyprland v0.51.1..."
    git clone --depth 1 --branch v0.51.1 \
      --recurse-submodules https://github.com/hyprwm/Hyprland "$HYPR_DIR"
else
    info "Usando fuentes existentes en $HYPR_DIR"
fi

info "Compilando Hyprland (3-5 minutos)..."
cd "$HYPR_DIR"
rm -rf build
cmake -B build -G Ninja \
  -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH="/usr/local;/usr"
ninja -C build -j"$(nproc)"
sudo ninja -C build install
sudo ldconfig
success "Hyprland instalado"

# ── PASO E: Resto del stack ─────────────────────────────────────────────────
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
echo -e "${GREEN}══════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Instalación completa                        ${NC}"
echo -e "${GREEN}══════════════════════════════════════════════${NC}"
echo ""
echo -e "  Hyprland: $(Hyprland --version 2>/dev/null | head -1 || echo 'instalado en /usr/local/bin')"
echo -e "  waybar:   $(waybar --version 2>/dev/null | head -1)"
echo -e "  kitty:    $(kitty --version 2>/dev/null | head -1)"
echo ""
echo -e "${YELLOW}Próximos pasos:${NC}"
echo "  1. Cierra sesión de GNOME"
echo "  2. En GDM haz clic en el engranaje ⚙"
echo "  3. Selecciona 'Hyprland' e inicia sesión"
echo ""
echo -e "${CYAN}Atajos básicos:${NC}"
echo "  Super+Return → Kitty    Super+Q → Cerrar ventana"
echo "  Super+D      → Wofi     Super+1..9 → Workspaces"
echo "  Print        → Captura  Super+Shift+S → Región"
