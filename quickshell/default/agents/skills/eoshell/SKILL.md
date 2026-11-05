---
name: eoshell
description: >
  REQUIRED for end-user customization of Linux desktop, window manager, or system config.
  Use when editing ANY file in ~/.config/, ~/.config/hypr/, ~/.config/eoshell/,
  ~/.config/alacritty/, ~/.config/foot/, ~/.config/kitty/, or ~/.config/ghostty/.
  Triggers: Hyprland, window rules, window behavior, animations, keybindings, monitors, gaps, borders,
  blur, opacity, eoshell-shell, bar, widgets, terminal config, themes, fonts, background,
  night light, idle, lock screen, screenshots, screen recording, reminders, layer rules, workspace
  settings, display config, appearance changes, and user-facing eoshell commands. Excludes Eoshell
  source development through `eoshell dev link` workflows.
---

# Eoshell Skill

Manage [Eoshell](https://eoshell.org/) Linux systems - a beautiful, fun, agentic Arch Linux distribution with Hyprland.

This skill is for end-user customization on installed systems.
It is not for contributing to Eoshell source code.

## Topic Guides

Deeper instructions for common areas live next to this file. Read the
matching guide before starting:

- [`hyprland.md`](hyprland.md) - keybindings, monitors, window rules, and other Hyprland config
- [`plugins.md`](plugins.md) - the Eoshell shell: bar layout, widgets, plugins, idle behavior
- [`theming.md`](theming.md) - themes, backgrounds, and fonts
- [`hooks.md`](hooks.md) - automation hooks that run on system events
- [`capture.md`](capture.md) - screenshots, screen recordings, OCR text capture, and file sharing
- [`contributing.md`](contributing.md) - reporting Eoshell bugs and submitting fixes upstream

## Critical Safety Rules

For privileged commands, follow the Privilege Escalation rules below: `sudo` when a terminal is available for the password prompt, `pkexec` when it is not. Do not wrap commands that already manage privilege elevation themselves.

**For end-user customization tasks, NEVER modify anything in `/usr/share/eoshell/`** - but READING is safe and encouraged.

This directory is owned by the eoshell package. Any local changes will be
overwritten on the next `eoshell update`.

```
/usr/share/eoshell/     # READ-ONLY - NEVER EDIT (reading is OK)
├── bin/                    # Command source (packaged binaries are on PATH)
├── config/                 # Default config templates
├── themes/                 # Stock themes
├── default/                # System defaults
├── shell/                  # Eoshell shell source and defaults
├── migrations/             # Update migrations
└── install/                # Installation scripts
```

**Reading `/usr/share/eoshell/` is SAFE and useful** - do it freely to:
- Understand how eoshell commands work: `eoshell theme set --help` or `cat $(which eoshell-theme-set)`
- See default configs before customizing: `cat "$EOSHELL_PATH/config/eoshell/shell.json"`
- Check stock theme files to copy for customization
- Reference default hyprland settings: `cat /usr/share/eoshell/default/hypr/*`

**Always use these safe locations instead:**
- `~/.config/` - User configuration (safe to edit)
- `~/.config/eoshell/themes/<custom-name>/` - Custom themes
- `~/.config/eoshell/hooks/` - Custom automation hooks

If the request is to develop Eoshell itself, this skill is out of scope. Follow repository development instructions instead of this skill.

## Privilege Escalation

For an interactive script or command run in a visible terminal, use `sudo` for
privileged work. Eoshell may grant passwordless `sudo` access to particular
commands, and the terminal is the appropriate place to request a password
when one is needed.

Use `pkexec` only when the caller cannot interact with a terminal or cannot
enter a password there, such as a command launched by an agent or a graphical
background process. Do not replace `sudo` with `pkexec` merely because a
command changes system state.

## System Architecture

Eoshell is built on:

| Component | Purpose | Config Location |
|-----------|---------|-----------------|
| **Arch Linux** | Base OS | `/etc/`, `~/.config/` |
| **Hyprland** | Wayland compositor/WM | `~/.config/hypr/` |
| **Eoshell shell** | Status bar + notifications (Quickshell) | `~/.config/eoshell/shell.json` |
| **Launcher/menus** | Quickshell menu | `~/.config/eoshell/extensions/eoshell-menu.jsonc` |
| **Alacritty/Foot/Kitty/Ghostty** | Terminals | `~/.config/<terminal>/` |
| **Eoshell OSD** | On-screen display | Quickshell plugin |

## Command Discovery

Eoshell ships a single `eoshell` CLI that dispatches to all `eoshell-*` binaries via `eoshell <group> <action>`. Always prefer this form — it is self-documenting and stable. The underlying `eoshell-*` binaries still exist on `PATH` and remain safe to read for source.

```bash
# List every documented command and its summary (--all includes hidden commands)
eoshell commands

# Show the commands inside a group
eoshell theme --help
eoshell refresh --help
eoshell restart --help

# Show help for a specific command (does not execute it)
eoshell theme set --help

# Machine-readable listing (binary, route, summary, args, aliases)
eoshell commands --json

# Read a command's source to understand it
cat $(which eoshell-theme-set)
```

### Command Groups

Run `eoshell --help` for the full list. The most common groups:

| Group | Purpose | Example |
|-------|---------|---------|
| `eoshell refresh` | Reset config to defaults (backs up first) | `eoshell refresh shell` |
| `eoshell restart` | Restart a service/app | `eoshell restart shell` |
| `eoshell toggle` | Toggle feature on/off | `eoshell toggle nightlight` |
| `eoshell theme` | Theme management | `eoshell theme set <name>` |
| `eoshell bar` | Bar layout and widgets | `eoshell bar move eoshell.clock --section right` |
| `eoshell plugin` | Manage/clone shell plugins | `eoshell plugin clone eoshell.clock` |
| `eoshell hook` | Install automation hooks | `eoshell hook install theme-set <script>` |
| `eoshell install` | Install optional software / packages | `eoshell install docker dbs` |
| `eoshell launch` | Launch apps | `eoshell launch browser` |
| `eoshell capture` | Screenshots and recordings | `eoshell capture screenshot` |
| `eoshell reminder` | Desktop notification reminders | `eoshell reminder 15 "Pickup Jack"` |
| `eoshell pkg` | Package management | `eoshell pkg add <pkg>` |
| `eoshell setup` | Interactive setup wizards | `eoshell setup security fingerprint` |
| `eoshell update` | System updates | `eoshell update` |

## Configuration Locations

Hyprland config lives in `~/.config/hypr/` — see [`hyprland.md`](hyprland.md).
The Eoshell shell (bar, notifications, plugins, idle) is configured in
`~/.config/eoshell/shell.json` — see [`plugins.md`](plugins.md).

### Terminals

```
~/.config/alacritty/alacritty.toml
~/.config/foot/foot.ini
~/.config/kitty/kitty.conf
~/.config/ghostty/config
```

**Command:** `eoshell restart terminal`

### Other Configs

| App | Location |
|-----|----------|
| btop | `~/.config/btop/btop.conf` |
| fastfetch | `/etc/fastfetch/config.jsonc` default; `~/.config/fastfetch/config.jsonc` user override |
| lazygit | `~/.config/lazygit/config.yml` |
| starship | `~/.config/starship.toml` |
| git | `~/.config/git/config` |

## Safe Customization Patterns

### Edit User Config Directly

For simple changes, edit files in `~/.config/`:

```bash
# 1. Read current config
cat ~/.config/hypr/bindings.lua

# 2. Backup before changes
cp ~/.config/hypr/bindings.lua ~/.config/hypr/bindings.lua.bak.$(date +%s)

# 3. Make changes with Edit tool

# 4. Apply changes
# - Hyprland: auto-reloads on save, but MUST validate with `hyprctl reload` and `hyprctl configerrors`
# - Eoshell shell: shell.json and user plugin code under ~/.config/eoshell/plugins/ hot-reload on save
# - Menus/launcher: ~/.config/eoshell/extensions/eoshell-menu.jsonc hot-reloads on save
# - Terminals: apply with `eoshell restart terminal` (reloads running terminals; foot picks changes up in new windows)
```

### Reset to Defaults -- ALWAYS SEEK USER CONFIRMATION BEFORE RUNNING

When customizations go wrong:

```bash
# Reset specific config (creates backup automatically)
eoshell refresh shell
eoshell refresh hyprland

# The refresh command:
# 1. Backs up current config with timestamp
# 2. Copies default from $EOSHELL_PATH/config/
# 3. Restarts the component where the refresh needs it (e.g. `refresh shell`)
```

## System Commands

```bash
eoshell update                  # Full system update
eoshell version                 # Show Eoshell version
eoshell debug --no-sudo --print # Debug info (ALWAYS use these flags)
eoshell system lock             # Lock screen
eoshell system shutdown         # Shutdown
eoshell system reboot           # Reboot
```

**IMPORTANT:** Always run `eoshell debug` with `--no-sudo --print` flags to avoid interactive sudo prompts that will hang the terminal.

## Troubleshooting

```bash
# Get debug information (ALWAYS use these flags to avoid interactive prompts)
eoshell debug --no-sudo --print

# Reset specific config to defaults
eoshell refresh <app>

# Refresh specific config file
# config-file path is relative to ~/.config/
# eg. `eoshell refresh config hypr/hyprland.lua` will refresh ~/.config/hypr/hyprland.lua
eoshell refresh config <config-file>

# Full reinstall of configs (nuclear option)
eoshell reinstall
```

## Decision Framework

When user requests system changes:

1. **Is it a stock eoshell command?** Use it directly
2. **Is it a config edit?** Edit in `~/.config/`, never `/usr/share/eoshell/`
3. **Is it a theme customization?** Follow [`theming.md`](theming.md); create a NEW custom theme directory
4. **Is it automation?** Follow [`hooks.md`](hooks.md); use `eoshell hook install` and the hook `.d` directories
5. **Is it a package install?** Use `eoshell pkg add <pkgs...>` (or `eoshell pkg aur add <pkgs...>` for AUR-only packages)
6. **Is it built-in shell/plugin code?** Follow [`plugins.md`](plugins.md); clone it with `eoshell plugin clone`, never edit the packaged copy
7. **Unsure if command exists?** Run `eoshell commands` (or `eoshell <group> --help` for one group)

### Reminder Requests

When the user asks to set a reminder, use `eoshell reminder <minutes> [message]` directly. Convert natural language durations to minutes and title-case short reminder labels when appropriate.

```bash
eoshell reminder 15 "Pickup Jack"
eoshell reminder 60 "Check laundry"
eoshell reminder show
eoshell reminder clear
```

## Out of Scope

This skill intentionally does not cover Eoshell source development. Do not use this skill for:
- Editing files in `/usr/share/eoshell/` (`bin/`, `config/`, `default/`, `shell/`, `themes/`, `migrations/`, etc.)
- Creating or editing migrations
- Running `eoshell dev ...` commands

## Example Requests

- "Change my theme to catppuccin" -> `eoshell theme set catppuccin`
- "Add a keybinding for Super+E to open file manager" -> Check existing bindings first, then use `o.rebind` to replace one or `o.bind` to add one in `~/.config/hypr/bindings.lua`
- "Configure my external monitor" -> `eoshell hyprland monitor scaling|resolution --monitor <name> ...` for scale and resolution; edit `~/.config/hypr/monitors.lua` only for rotation and the other extras in hyprland.md
- "Make the window gaps smaller" -> Edit `~/.config/hypr/looknfeel.lua`
- "Turn on night light" -> `eoshell toggle nightlight` (for time-based schedules, edit `~/.config/hypr/hyprsunset.conf` profiles, then `eoshell restart hyprsunset`)
- "Set a reminder to pickup jack in 15 minutes" -> `eoshell reminder 15 "Pickup Jack"`
- "Show my reminders" -> `eoshell reminder show`
- "Clear all reminders" -> `eoshell reminder clear`
- "Customize the catppuccin theme colors" -> Overlay: put an edited `colors.toml` in `~/.config/eoshell/themes/catppuccin/`, then re-apply the theme (see `theming.md`)
- "Run a script every time I change themes" -> Install it with `eoshell hook install theme-set <script>`
- "Change how workspace labels are rendered" -> Clone `eoshell.workspaces`, which switches the bar to `<username>.workspaces`, then edit the clone
- "Lock after ten minutes" -> Set `idle.lock` to `600` in `~/.config/eoshell/shell.json`
- "Reset shell/bar to defaults" -> `eoshell refresh shell`
- "Record my screen" -> `eoshell screenrecord --fullscreen`, then `eoshell screenrecord --stop-recording` (see `capture.md`)
- "Report this bug to Eoshell" -> Gather diagnostics and a capture of the problem, then file it (see `contributing.md`)
