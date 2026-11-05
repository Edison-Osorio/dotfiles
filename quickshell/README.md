# eoshell

Mi shell de escritorio sobre Quickshell (barra, paneles, widgets). Es código propio,
versionado aquí; no depende de ningún repositorio externo ni se sincroniza con uno.

Parte de su estructura (plugins, barra, temas) se tomó como referencia de
[Omarchy](https://github.com/basecamp/omarchy) (MIT, © David Heinemeier Hansson);
el aviso de licencia original está en `LICENSE-upstream`.

- `shell/`   QML: barra, paneles y plugins. `shell/plugins/stats` (`mi.stat`) es propio.
- `user/shell.json`   mi configuración; `~/.config/eoshell/shell.json` apunta aquí (symlink).
- `bin/`, `default/`, `config/`, `themes/`, `docs/`   soporte heredado; muchos scripts de `bin/`
  asumen Arch (pacman/yay). Se irán podando.

Lanzar/detener: `eoshell-test start|stop|toggle|log`
