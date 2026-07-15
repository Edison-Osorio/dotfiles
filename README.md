# Dotfiles — respaldo pre-migración a Omarchy

Respaldo de la configuración de escritorio y desarrollo de este sistema (Fedora +
Hyprland), hecho antes de migrar a [Omarchy](https://omarchy.org). Generado el
2026-07-15.

## Qué contiene

```
config/            # ~/.config de cada app
  hypr/             Hyprland: hyprland.conf, hyprlock, hypridle, monitors, scripts/
  waybar/            barra: config.jsonc, style.css, scripts/
  wofi/              launcher: config, style.css, power-style.css
  wlogout/           menú de apagado: layout, style.css
  dunst/             notificaciones: dunstrc
  nvim/              LazyVim: init.lua, lazyvim.json, lazy-lock.json
  kitty/             kitty.conf
  lazygit/           config.yml
  zed/               settings.json
  nwg-look/          tema GTK
  nwg-displays/      layout de monitores (nota: no llegó a aplicarse en DP-1,
                     ver home/.zshrc y monitors.conf para el estado real)
  Code/User/         settings.json de VS Code
  starship.toml      prompt de shell
  mimeapps.list      apps por defecto

home/               # dotfiles de $HOME
  .zshrc .bashrc .bash_profile .gitconfig .gitignore_global

local/bin/          # scripts personalizados (no binarios de terceros)
  git-identity        cambia identidad git por repo
  power-menu.sh
  pynvim-python

systemd/user/       # unidades de usuario
  battery-monitor.service / .timer
  xdg-desktop-portal.service.d/override.conf

wallpapers/
  wallpaper.png      referenciado en hyprland.conf vía swww

packages/           # solo referencia, no se restauran automáticamente
  dnf-installed.txt        paquetes Fedora instalados (nombres no aplican en Arch)
  flatpak-apps.txt
  vscode-extensions.txt
  oh-my-zsh-plugins.txt    plugins de terceros y de dónde clonarlos
```

## Qué NO se incluyó (a propósito)

- **Llaves SSH** (`~/.ssh`) — decisión explícita, migrar por un canal seguro aparte.
- Historiales de shell (`.bash_history`, `.zsh_history`), cachés (`.zcompdump*`),
  credenciales de apps (`google-chrome`, `evolution`, `pulse`, etc.) y `.claude.json`.
- El código fuente de `zsh-autosuggestions` / `zsh-syntax-highlighting`: son repos
  git de terceros, se reclonan (ver `packages/oh-my-zsh-plugins.txt`).
- Fuentes (JetBrainsMono Nerd Font en `~/.local/share/fonts`): pésalas aparte si
  Omarchy no las trae por defecto (normalmente sí las incluye).

## Restaurar en el sistema nuevo (Omarchy)

Omarchy ya trae su propia configuración por defecto de Hyprland/Waybar/etc.
**No copies este `config/` encima a ciegas** — revisa diffs antes de sobrescribir,
porque Omarchy puede usar rutas, keybinds o un launcher distinto (p. ej. `walker`
en vez de `wofi`) y tiene su propio sistema de temas.

1. Clona/copia este repo al equipo nuevo.
2. Instala lo que Omarchy no traiga: `nvim` (LazyVim ya suele venir), `kitty`,
   `lazygit`, `dunst`, `zed`, `nwg-look`/`nwg-displays` si los sigues usando.
3. Compara cada archivo de `config/<app>/` contra el equivalente que Omarchy puso
   en `~/.config/<app>/` y copia solo lo que quieras conservar, por ejemplo:
   ```bash
   diff ~/Backups/dotfiles/config/kitty/kitty.conf ~/.config/kitty/kitty.conf
   cp ~/Backups/dotfiles/config/kitty/kitty.conf ~/.config/kitty/kitty.conf
   ```
4. Dotfiles de home: revisa `home/.zshrc` antes de reemplazar el tuyo — trae
   `plugins=(...)` de oh-my-zsh y el `source` de starship. Fusiona a mano si
   Omarchy ya configuró zsh a su manera.
5. Wallpaper: `cp wallpapers/wallpaper.png ~/.local/share/wallpapers/` y ajusta
   el comando `swww img` (o el que use Omarchy) en `hyprland.conf`.
6. Scripts: `cp local/bin/* ~/.local/bin/ && chmod +x ~/.local/bin/*`.
7. Servicios systemd de usuario:
   ```bash
   cp -r systemd/user/* ~/.config/systemd/user/
   systemctl --user daemon-reload
   systemctl --user enable --now battery-monitor.timer
   ```
8. Plugins zsh de terceros:
   ```bash
   git clone https://github.com/zsh-users/zsh-autosuggestions \
     ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
   git clone https://github.com/zsh-users/zsh-syntax-highlighting \
     ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
   ```
9. VS Code: instala extensiones desde `packages/vscode-extensions.txt`
   (`code --install-extension <id>` por cada línea, sin la versión) y copia
   `config/Code/User/settings.json`.
10. `packages/dnf-installed.txt` es solo referencia de qué tenías en Fedora —
    los nombres de paquete no se mapean 1:1 a pacman/AUR en Arch.
