# Base Quickshell (derivada de Omarchy)

Fork de https://github.com/basecamp/omarchy en el commit `6194f46` (2026-11-05).
Es **mi base, no un espejo**: se edita libremente. No se sincroniza con upstream.

- `shell/`  QML del shell (barra, paneles, plugins). Único cambio respecto a upstream:
  se quitó la primera línea `//@ pragma OmarchyLoadPatch` (solo la entiende el Quickshell parcheado de Omarchy).
- `bin/`, `default/`, `config/`, `docs/`, `themes/` copiados tal cual (themes sin `backgrounds/`).
  Muchos scripts de `bin/` asumen Arch (pacman/yay): ver docs antes de usarlos.
- `user/shell.json`  mi configuración de la barra; `~/.config/omarchy/shell.json` es un symlink a este archivo.

Lanzar/detener: `omarchy-shell-test start|stop|toggle|log`
