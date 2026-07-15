#!/usr/bin/env bash
# Reemplaza VSCode por Zed + instala Postman
set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; BOLD='\033[1m'; NC='\033[0m'
info()    { echo -e "${CYAN}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
section() { echo -e "\n${BOLD}${YELLOW}━━━ $* ━━━${NC}\n"; }

# ── 1. ELIMINAR VSCODE ───────────────────────────────────────────────────────
section "Eliminando VSCode"

if command -v code &>/dev/null; then
  info "Desinstalando VSCode..."
  sudo dnf remove -y code
  success "VSCode eliminado"
else
  success "VSCode no estaba instalado"
fi

if [ -f /etc/yum.repos.d/vscode.repo ]; then
  sudo rm /etc/yum.repos.d/vscode.repo
  success "Repo VSCode eliminado"
fi

# ── 2. ZED ───────────────────────────────────────────────────────────────────
section "Zed Editor"

if ! command -v zed &>/dev/null; then
  info "Instalando Zed via instalador oficial..."
  curl -f https://zed.dev/install.sh | sh
  success "Zed instalado en ~/.local/bin/zed"
else
  info "Actualizando Zed..."
  curl -f https://zed.dev/install.sh | sh
  success "Zed actualizado: $(zed --version 2>/dev/null || echo 'ok')"
fi

# Asegurarse que ~/.local/bin está en el PATH (ya debería estar por .zshrc)
if ! grep -q '\.local/bin' ~/.zshrc 2>/dev/null; then
  printf '\nexport PATH="$HOME/.local/bin:$PATH"\n' >> ~/.zshrc
fi

# ── 3. POSTMAN ───────────────────────────────────────────────────────────────
section "Postman"

if ! flatpak list 2>/dev/null | grep -q "com.getpostman.Postman"; then
  info "Instalando Postman desde Flathub..."
  flatpak install -y flathub com.getpostman.Postman
  success "Postman instalado"
else
  success "Postman ya está instalado"
fi

# ── RESUMEN ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  Editores listos                                 ${NC}"
echo -e "${GREEN}${BOLD}══════════════════════════════════════════════════${NC}"
echo ""
command -v code &>/dev/null && echo "  ✗ VSCode aún presente" || echo "  ✓ VSCode eliminado"
command -v zed  &>/dev/null && echo "  ✓ Zed instalado" || echo "  ~ Zed: reinicia terminal para activar PATH"
flatpak list 2>/dev/null | grep -q "Postman" && echo "  ✓ Postman instalado"
echo ""
echo -e "${YELLOW}Primeros pasos en Zed:${NC}"
echo "  zed .                    → abrir proyecto actual"
echo "  zed ~/.config/nvim       → editar config de nvim"
echo ""
echo -e "${YELLOW}Configurar IA en Zed:${NC}"
echo "  1. Abre Zed → Ctrl+Shift+P → 'zed: open settings'"
echo "  2. Agrega tu ANTHROPIC_API_KEY para usar Claude"
echo ""
echo -e "${YELLOW}Extensiones recomendadas para tu stack:${NC}"
echo "  Python, TypeScript, ESLint, Prettier, Docker, GitLens"
