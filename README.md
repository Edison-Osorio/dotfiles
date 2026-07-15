# Dotfiles — Fedora + Hyprland (compilado desde código fuente)

Respaldo de la configuración de escritorio y desarrollo de este sistema.
**La base real es Fedora** (43/44) con Hyprland compilado desde código fuente
(no viene de COPR ni RPM), más un stack de desarrollo propio. Generado el
2026-07-15.

Más adelante pienso usar parte de esto como punto de partida en
[Omarchy](https://omarchy.org) (Arch), pero ahí solo aplican algunas piezas —
ver la sección final.

## Qué contiene

```
config/            # ~/.config de cada app
  hypr/             Hyprland: hyprland.conf, hyprlock, hypridle, monitors, scripts/
                     + scripts de instalación en Fedora (ver "Restaurar en Fedora")
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

packages/           # baseline real del sistema Fedora
  dnf-installed.txt        salida de `dnf list --installed` en Fedora
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
- Fuentes (JetBrainsMono Nerd Font en `~/.local/share/fonts`): pésalas aparte.

## Restaurar en Fedora (ruta principal)

Este repo ya trae, dentro de `config/hypr/`, los scripts reales que se usaron
para construir el sistema. Úsalos en este orden en el equipo Fedora nuevo:

1. **`setup-repos.sh`** — habilita RPM Fusion, los COPR necesarios
   (`solopasha/hyprland`, `tofik/nwg-shell`) y herramientas base
   (`gh`, `direnv`, `httpie`, Flathub, Bruno, DBeaver).
2. **`build-hyprland.sh`** → **`build-hyprland-resume.sh`** →
   **`build-hyprland-final.sh`** — compilan Hyprland desde código fuente
   (aquamarine v0.9.5 + Hyprland v0.51.1), instalan vía `dnf` el resto del
   stack (`waybar`, `kitty`, `wofi`, `dunst`, `swww`, `grim`, `slurp`,
   `playerctl`, `brightnessctl`, `blueman`, `pavucontrol`, `nwg-look`, etc.)
   y registran la sesión Hyprland en GDM. `build-hyprland-resume.sh` existe
   para retomar si el paso de `aquamarine` ya quedó instalado.
3. **`setup-devenv.sh`** — entorno de desarrollo completo (Python, TypeScript,
   Java, MongoDB, MySQL, Docker, VS Code, Neovim, kitty, Node). Es largo
   (~1500 líneas): revísalo antes de correrlo, no todo puede aplicar tal cual
   en un equipo nuevo.
4. **`setup-editors.sh`** — reemplaza VS Code por Zed + instala Postman
   (ejecútalo solo si quieres ese cambio).
5. **`setup-conservation.sh`** — modo de conservación de batería, va de la
   mano con `systemd/user/battery-monitor.service` y `.timer`.
6. Copia el resto de la config:
   ```bash
   cp -r config/hypr config/waybar config/wofi config/wlogout config/dunst \
         config/nvim config/kitty config/lazygit config/zed config/nwg-look \
         config/nwg-displays ~/.config/
   cp config/starship.toml config/mimeapps.list ~/.config/
   cp -r config/Code/User/* ~/.config/Code/User/
   cp home/.zshrc home/.bashrc home/.bash_profile home/.gitconfig home/.gitignore_global ~/
   cp local/bin/* ~/.local/bin/ && chmod +x ~/.local/bin/*
   cp wallpapers/wallpaper.png ~/.local/share/wallpapers/
   cp -r systemd/user/* ~/.config/systemd/user/
   systemctl --user daemon-reload
   systemctl --user enable --now battery-monitor.timer
   ```
7. Plugins zsh de terceros:
   ```bash
   git clone https://github.com/zsh-users/zsh-autosuggestions \
     ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
   git clone https://github.com/zsh-users/zsh-syntax-highlighting \
     ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
   ```
8. VS Code: `packages/vscode-extensions.txt` trae los IDs con versión
   (`code --install-extension <id-sin-version>` por cada línea).
9. `packages/dnf-installed.txt` es la referencia completa de paquetes Fedora
   por si falta algo puntual que no cubren los scripts anteriores.

## Portabilidad a Omarchy (parcial, no ruta principal)

Omarchy (Arch) ya trae Hyprland como binario, su propio launcher (`walker` en
vez de `wofi`), su propio tema y gestión de dotfiles. **No apliquen los
scripts de `build-hyprland*.sh` ni `setup-repos.sh`/`setup-devenv.sh`** —
son específicos de Fedora/dnf.

De este repo, lo que sí tiene sentido reutilizar como base en Omarchy:

- `config/nvim/` (LazyVim), `config/kitty/kitty.conf`, `config/lazygit/`,
  `config/starship.toml`, `home/.zshrc` (revisa los `plugins=(...)`) —
  configuración de terminal/editor, agnóstica del compositor.
- `wallpapers/wallpaper.png` — reutilizable con el gestor de wallpaper que
  traiga Omarchy.
- `config/hypr/hyprland.conf`, `config/waybar/`, `config/dunst/` — solo como
  referencia de binds/reglas para adaptar manualmente a la estructura que
  Omarchy ya trae; no copiarlos encima sin comparar antes.
- `packages/vscode-extensions.txt` y `packages/oh-my-zsh-plugins.txt` — la
  lista de extensiones/plugins sí es portable tal cual.

Todo lo demás (`packages/dnf-installed.txt`, los scripts de `config/hypr/*.sh`,
las unidades `systemd/user/`) es específico de este sistema Fedora y no aplica
en Arch/Omarchy.
