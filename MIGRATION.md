# Checklist de migración: Fedora → Arch + Omarchy

Guía paso a paso para instalar Arch con cifrado LUKS y Omarchy encima, y
luego reaplicar la config de este repo. Pensada para seguirse incluso desde
el USB live de Arch, sin depender de este equipo Fedora.

## 0. Antes de borrar este equipo (hacer AHORA, en Fedora)

- [ ] Confirmar que `dotfiles` está pusheado y al día:
  `cd ~/Backups/dotfiles && git status && git log --oneline -3`
- [ ] Llaves SSH: **no están en el repo** (decisión a propósito). Elige una:
  - Copiar `~/.ssh/id_ed25519*` a un USB aparte y restaurarlas en Arch, o
  - Generar un par nuevo en Arch (`ssh-keygen -t ed25519`) y añadirlo en
    GitHub → Settings → SSH Keys (más limpio, recomendado).
- [ ] Descargar la ISO de Arch y grabarla en USB (`dd`, Ventoy o Rufus).
- [ ] En BIOS/UEFI: **desactivar Secure Boot** (simplifica todo el proceso
  con Limine; reactivarlo después es un tema aparte, más avanzado).
- [ ] Confirmar que no falta nada suelto fuera del repo (fotos, proyectos
  sin pushear, etc.) — este repo cubre config, no datos personales.

## 1. Boot del live USB de Arch

```bash
# conectar red si es WiFi
iwctl
# dentro de iwctl: station wlan0 connect "TU_RED"
# salir con exit

ping -c1 archlinux.org   # confirmar internet
```

## 2. Instalar Arch base con `archinstall` (con cifrado)

```bash
archinstall
```

Elegir en el asistente:
- **Filesystem**: btrfs, con compresión activada
- **Disk encryption**: LUKS, define una passphrase que puedas escribir
  siempre desde teclado cableado o dongle 2.4GHz (Bluetooth no sirve en
  el prompt de arranque)
- **Bootloader**: Limine
- **Audio**: pipewire
- **Network**: copiar configuración del ISO
- **Hostname / timezone / mirrors**: los tuyos
- Crear un **usuario normal con sudo** (no vas a instalar Omarchy como root)
- Password de root

Al terminar, reinicia y quita el USB.

## 3. Primer arranque en Arch base

- Login con el usuario creado.
- Verificar prerequisitos antes de instalar Omarchy:
  ```bash
  cat /etc/arch-release        # debe existir
  uname -m                     # debe ser x86_64
  whoami                       # NO debe ser root
  pacman -Qs gnome-shell kde-plasma-desktop   # debe salir vacío
  ```

## 4. Instalar Omarchy

```bash
curl -fsSL https://omarchy.org/install | bash
```

Sigue las instrucciones del propio instalador (tema, hostname de sesión,
etc.). Al terminar, reinicia y entra a la sesión Hyprland de Omarchy.

## 5. Traer este repo (privado) desde cero, sin llaves guardadas

En un sistema recién instalado no tienes `gh` autenticado ni llaves SSH
todavía. Opción más simple, con `gh` (Omarchy trae `git`; instala `gh` si
falta con `sudo pacman -S github-cli`):

```bash
gh auth login
# elige: GitHub.com → HTTPS → login con navegador
# te da un código de un solo uso: entra desde el celular a
# github.com/login/device y pégalo ahí

gh repo clone Edison-Osorio/dotfiles ~/Backups/dotfiles
```

## 6. Reaplicar configuración (selectivo, NO copiar todo encima)

Sigue la sección **"Portabilidad a Omarchy"** de `README.md` de este repo.
Resumen rápido de lo que sí aplica tal cual:

```bash
cd ~/Backups/dotfiles

cp -r config/nvim ~/.config/
cp config/kitty/kitty.conf ~/.config/kitty/kitty.conf
cp -r config/lazygit ~/.config/
cp config/starship.toml ~/.config/
cp wallpapers/wallpaper.png ~/.local/share/wallpapers/wallpaper.png
```

`home/.zshrc`, `config/hypr/hyprland.conf`, `config/waybar/`,
`config/dunst/`: revisar con `diff` contra lo que Omarchy ya dejó en
`~/.config/` y fusionar a mano lo que quieras conservar (binds, plugins de
zsh, etc.) — no sobrescribir de una.

## 7. Cosas fuera del repo (Arch usa `pacman`/AUR, no `dnf`)

Los scripts `config/hypr/*.sh` (setup-repos.sh, setup-devenv.sh, build-hyprland*.sh)
**son de Fedora y no aplican aquí** — Omarchy ya te dio Hyprland compilado
y el stack base. Lo que sí toca reinstalar manualmente con `pacman`/`yay`:

- [ ] Docker (`sudo pacman -S docker docker-compose`, `sudo systemctl enable --now docker`)
- [ ] Node/nvm, Python/pyenv, lenguajes que usabas en `setup-devenv.sh`
- [ ] VS Code o Zed — instala extensiones desde `packages/vscode-extensions.txt`
      (los nombres de paquete/extensión sí son iguales cross-distro)
- [ ] Plugins zsh de terceros:
  ```bash
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
  ```
- [ ] Si usas Avante/CodeCompanion en Neovim: `export ANTHROPIC_API_KEY=sk-ant-...`
      en tu `.zshrc` fusionado.

## 8. Verificación final

- [ ] WiFi y Bluetooth desde el applet de Omarchy (el motivo #1 de la migración)
- [ ] Lock screen funcionando (Omarchy ya trae uno propio; no necesitas tu
      `hyprlock.conf` viejo salvo que quieras ajustar estilo)
- [ ] Wallpaper aplicado en todos los monitores
- [ ] `nvim`, `kitty`, `lazygit`, `starship` con tu config
- [ ] `git-identity` y demás scripts de `local/bin/` copiados y con `+x`
