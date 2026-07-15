#!/usr/bin/env bash
# Pasos finales: instalar Hyprland, stack completo y sesión GDM
set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${CYAN}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }

HYPR_DIR="$HOME/.local/src/hyprland-build/Hyprland"

# ── Verificar que el binario existe ────────────────────────────────────────
if [ ! -f "$HYPR_DIR/build/Hyprland" ]; then
    echo -e "${RED}[ERROR]${NC} No se encontró el binario compilado en $HYPR_DIR/build/Hyprland"
    echo "Asegúrate de haber compilado Hyprland antes de ejecutar este script."
    exit 1
fi
success "Binario Hyprland encontrado ($(du -h "$HYPR_DIR/build/Hyprland" | cut -f1))"

# ── PASO D final: Instalar Hyprland ────────────────────────────────────────
info "Instalando Hyprland en /usr/local..."
cd "$HYPR_DIR"
sudo ninja -C build install
sudo ldconfig
success "Hyprland instalado en /usr/local/bin/Hyprland"

# ── PASO E: Stack completo ──────────────────────────────────────────────────
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
echo -e "  Hyprland : $(/usr/local/bin/Hyprland --version 2>/dev/null | head -1)"
echo -e "  waybar   : $(waybar --version 2>/dev/null | head -1)"
echo -e "  kitty    : $(kitty --version 2>/dev/null | head -1)"
echo -e "  swww     : $(swww --version 2>/dev/null | head -1)"
echo -e "  wofi     : $(wofi --version 2>/dev/null | head -1)"
echo ""
echo -e "${YELLOW}Próximos pasos:${NC}"
echo "  1. Cierra sesión de GNOME"
echo "  2. En GDM haz clic en el engranaje ⚙ junto al botón de login"
echo "  3. Selecciona 'Hyprland' e inicia sesión"
echo ""
echo -e "${CYAN}Atajos desde el primer inicio:${NC}"
echo "  Super+Return      → Kitty (terminal)"
echo "  Super+D           → Wofi (lanzador de apps)"
echo "  Super+Q           → Cerrar ventana"
echo "  Super+1..9        → Cambiar workspace"
echo "  Print             → Captura pantalla completa"
echo "  Super+Shift+S     → Captura de región"
