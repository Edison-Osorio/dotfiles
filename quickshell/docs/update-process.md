# Eoshell update process

This document describes the intended update behavior now that Eoshell is
package-backed. It covers the blessed update path plus what happens when a user attempts to
bypass it:

1. `eoshell update` — the blessed interactive Eoshell update flow.
2. `sudo pacman -Syu` — guarded by Eoshell and aborted with instructions unless
   the user explicitly bypasses the guard.

The design goal is:

- `eoshell update` owns the visible update pipeline: package transaction,
  migrations, post-update hooks, update-state refresh, and restart checks.
- Migrations run per-user after pacman finishes, because they may need `$HOME`,
  DBus/session state, a graphical session, sudo, or user interaction.
- Users who bypass `eoshell update` are nudged back by the pacman guard; if they
  explicitly bypass it, their session is notified when migrations are pending.

## State and coordination files

| Path | Owner | Purpose |
| --- | --- | --- |
| `${XDG_RUNTIME_DIR:-/tmp}/eoshell-update.lock` | user | Prevent overlapping update runs. Owned by `eoshell-update-lock`; compatibility wrappers inherit/respect it. |
| `${XDG_RUNTIME_DIR}/eoshell-update-stay-awake/` | user | Private mode-0700 inhibitor coordination state. If no runtime directory is available, the helper uses the validated mode-0700 `/tmp/eoshell-$UID/` fallback. |
| `/tmp/eoshell-update.log` | user | Transcript of `eoshell update`, used by `eoshell-update-analyze-logs`. |
| `~/.local/state/eoshell/current/` | user | Generated active theme, selected theme name, and current background symlink. |
| `~/.local/state/eoshell/migrations/` | user | Per-user migration markers. |
| `~/.local/state/eoshell/reboot-required` | user | Optional reboot marker checked by `eoshell-update-restart`. |
| `~/.local/state/eoshell/restart-*-required` | user | Optional service/app restart markers checked by `eoshell-update-restart`. The shell needs no marker: it is restarted unconditionally after every update. |

## Migration layout

See [`migrations.md`](../agents/skills/migrations.md) for the full migration model, authoring
guidelines, and troubleshooting notes.

Migrations live in:

```text
migrations/*.sh
```

They run as the current user through:

```bash
eoshell-migrate
```

Completion state is per-user:

```text
~/.local/state/eoshell/migrations/<migration filename>
```

Every user gets a chance to run every migration. Migrations run as the user;
privileged work should invoke the appropriate helper or privilege prompt.
Migrations must be idempotent; if one user already applied a machine-wide repair,
the migration should no-op for other users.

When invoked by the update, migrations share its single sudo authorization. The standalone migration runner has its own security changes in the migration-boundary PR; this update change does not establish that standalone boundary. Historical migrations remain strictly ordered.

For watchers and diagnostics, `eoshell-migrate --pending` prints pending
migration names and exits `0` when any are pending. When no migrations are
pending, it prints nothing and exits non-zero.

## Raw pacman guard

The `eoshell` package installs an ALPM pre-transaction hook alongside its guard
binary:

```text
/usr/share/libalpm/hooks/00-eoshell-update-guard.hook
/usr/bin/eoshell-update-pacman-guard
```

It triggers on package upgrades and runs:

```bash
eoshell-update-pacman-guard
```

The guard detects direct pacman system-upgrade commands like `pacman -Syu` or
`pacman --sync --refresh --sysupgrade`. If the upgrade was not launched by an
Eoshell update command, the hook exits non-zero with `AbortOnFail`, which stops
the transaction before packages are changed.

`eoshell-update-system-pkgs`, `eoshell-refresh-pacman`, `eoshell-reinstall-pkgs`,
and `eoshell-channel-set` run pacman through the hidden `eoshell-update-pacman`
helper (the v4 upgrader sets `EOSHELL_UPDATE_PACMAN=1` directly):

```bash
sudo env EOSHELL_UPDATE_PACMAN=1 systemd-run --scope --quiet --collect pacman ...
```

so the guard allows Eoshell-owned update flows. The `systemd-run --scope`
wrapper registers the transaction as a PID 1 scope: upgrading systemd reexecs
the system and user managers mid-transaction, and a pacman left inside a
user-session scope can be SIGKILLed by that reexec. On unbooted systems (such
as the installer chroot) the helper runs pacman directly. A user can intentionally bypass
the guard with:

```bash
sudo env EOSHELL_ALLOW_DIRECT_PACMAN=1 pacman -Syu
```

The guard does not start `eoshell update` itself because pacman is already in a
transaction setup path; it only aborts with instructions.

The `eoshell` package also installs ALPM hooks for `eoshell-settings` / `eoshell-settings-dev` installs and upgrades. The pre-transaction hook runs `eoshell-hyprland-reload-guard pause` to disable live Hyprland config reloads while `/usr/share/eoshell/default/hypr/**` is replaced. The post-transaction hook runs `eoshell-hyprland-reload-guard resume`, forces one `hyprctl reload`, and restores the session's previous `misc.disable_autoreload` and `debug.suppress_errors` values. A session whose Hyprland binary the same transaction replaced is left paused with errors hidden instead: it predates the new config, and both settings go away when it restarts on the new binary.

## Path 1: `eoshell update`

High-level flow:

```text
eoshell-update
  ├─ ensure transcript logging through script(1) → /tmp/eoshell-update.log
  ├─ eoshell-update-lock
  │    └─ acquire the update lock and run eoshell-update inside it
  ├─ eoshell-update-requires-free-space
  │    └─ abort below the configured free-space threshold on /
  ├─ confirm unless -y
  ├─ authorize sudo once, then keep the timestamp fresh in the background
  ├─ eoshell-update-pkg-prune
  │    └─ trim the pacman cache to two versions per package, deliberately
  │       before the snapshot since the cache lives on the snapshotted subvolume
  ├─ create snapper snapshot (skipped silently without snapper; snapper
  │  installed but unconfigured fails the snapshot loudly, pointing at
  │  install/config/snapper.sh, and the update continues without one)
  ├─ eoshell-update-stay-awake start
  ├─ run system-package updates
  ├─ restart the shell when migrations are pending, so they reach current code
  ├─ run migrations
  ├─ automatically remove orphan packages and run log analysis
  ├─ clear the shell update indicator: the update just installed what it showed
  ├─ restart marked services and the shell
  ├─ run the post-update hook, then update mise tools (a failed tool update
  │  warns and the update continues)
  ├─ update AUR packages
  ├─ eoshell-update-boot, then stop the keepalive
  │    └─ the platform's boot package proves the boot files boot the updated system
  ├─ eoshell-update-stay-awake stop
  │    └─ release the sleep inhibitor and restore shell idle state, if changed
  └─ offer the unprivileged reboot prompt, only when the boot files were verified
```

Important behavior:

- `eoshell update`, `eoshell-refresh-pacman` and `eoshell-channel-set` are ordinary scripts that run with the caller's environment, so hooks and mise see the user's own PATH. They gain no privilege of their own beyond the `sudo` calls they make.
- In dev-link mode, `eoshell update` fast-forwards the active checkout from its configured upstream before changing system packages or running migrations.
- Sudo behaves as it does everywhere else: one password is good for 10 minutes in the same terminal (`etc/sudoers.d/eoshell-sudo-timeout`), and no Eoshell command invalidates it. The update asks once right after confirmation (it runs inside `script`'s own pseudo-terminal, so a password typed in the calling terminal does not carry in), then a background keepalive refreshes the timestamp every minute so long downloads, migrations, hooks, AUR builds, and mise never outlast it. Every step shares that authorization, and the keepalive stops after the boot check. The authorization runs a command rather than `sudo -v`, so passwordless sudo still needs no prompt. Stay-awake reuses a cached authorization non-interactively when it has no terminal, rather than asking through polkit.
- AUR packages build against the upgraded system, so they run after it, under the same authorization as everything else.
- Sleep inhibition authenticates before detaching, drops the held command back to the caller, and closes both update lock descriptors before the persistent process starts. Cleanup accepts only caller-owned, mode-0600, single-link state and revalidates the recorded PID, process start time, owner, and random token immediately before every signal.
- Channel switching swaps the `eoshell`/`eoshell-dev` pair with a direct `pacman -S`, since the refresh before it can already have installed an older release without this tree's helpers, then hands off to the destination's own `eoshell update`.
- `-y` exports `EOSHELL_UPDATE_UNATTENDED=1` and suppresses Eoshell confirmation prompts. Conflict handoff reports and skips instead of blocking. Orphan packages are automatically removed during every update. Privileged commands still require the one sudo authorization.
- The free-space requirement uses a 10 GiB threshold and stops the update before
  confirmation when it is not met. If free space cannot be determined, the
  check is silently skipped. Set `EOSHELL_UPDATE_FORCE=1` to bypass the check.
- `eoshell update` checks/runs migrations in the same visible terminal via
  `eoshell-migrate` after pacman finishes.
- A failure should leave enough output in `/tmp/eoshell-update.log` and the
  terminal transcript to debug.
- The boot check is the [lifecycle dispatch](lifecycle-dispatch.md) operation `update-verify`, a no-op on platforms whose boot chain needs no handling of its own, x86 included: nothing runs and nothing asks for root. It is the last sudo-capable step, after AUR packages, so it also covers the initramfs rebuilds they trigger. When it fails, the update finishes its remaining steps, then exits non-zero without the reboot prompt: the update is not finished. A machine without its platform's boot package at all predates it: the update warns that its boot files were not verified and finishes. There is no check before the packages change: where `eoshell-hw-platform` can't tell the platform, the update installs its packages, and the update then fails verification, without the reboot prompt.

## Path 2: direct `sudo pacman -Syu` attempt

High-level flow:

```text
sudo pacman -Syu
  ├─ pre-transaction guard aborts and tells the user to run eoshell update
  └─ if explicitly bypassed, upgrades eoshell and related packages
  └─ at that user's next login
       ├─ graphical-session.target starts
       ├─ eoshell-migrate-notify.service starts after it
       ├─ eoshell-migrate-notify checks eoshell-migrate --pending
       ├─ if this user has missing migration state, show notification
       └─ click opens terminal: eoshell-migrate
```

Login is deliberately the only trigger. A watcher on the packaged migration
directory cannot distinguish a bypassed `pacman -Syu` from the package
transaction inside a normal `eoshell update`, so it fired notifications for
migrations that `eoshell-migrate` was about to apply in the visible update
terminal. The retired unit was `eoshell-update-user-notify.path`.

Retiring that watcher through a migration cannot come in time for the update
that retires it: pacman writes the migration directory, the watcher fires, and
only then does `eoshell-migrate` reach the migration that stops it. So the
notifier also refuses to run while `eoshell update` holds its
`$XDG_RUNTIME_DIR/eoshell-update.lock`, which covers the stale watcher and any
trigger added later — during an update, every pending migration is by
definition already being applied a step away. It checks again after waiting for
the notification server, since that wait is long enough for an update to start
underneath it.

The notifier reads only its own user's runtime directory, never the `/tmp` path
`eoshell-update` falls back to when `XDG_RUNTIME_DIR` is unset. A shared lock
file belongs to whoever created it first, so honouring it would let one user
silence another user's notification. Missing an update and showing a redundant
toast is the better failure.

Suppression is why `eoshell-update-stay-awake` starts its sleep inhibitor with
the lock descriptor closed. That inhibitor outlives the step that starts it, so
an update killed before cleanup would otherwise leave it holding the flock
indefinitely — blocking later updates and, now that the notifier reads the same
lock, silencing migration notifications at every login.

Fallbacks:

- `eoshell-provision-first-run` enables `eoshell-migrate-notify.service`, which also
  covers users created after install: their per-user migration markers are
  missing, so their first login prompts them to run every shipped migration.
- The package ships `eoshell-update-user-notify.service` as a symlink onto
  `eoshell-migrate-notify.service`. Users set up before the rename hold an
  absolute `graphical-session.target.wants` symlink to the old path, and the
  migration that repoints it only runs for users who run an update — the
  opposite of who the notifier is for. The alias can be dropped once installs
  have run migration `1785095882`.
- The notifier is ordered after `graphical-session.target`, so an action that
  launches through `uwsm-app` cannot block the target that gates UWSM's app
  daemon.
- The notifier waits for a live notification server before sending, because
  `graphical-session.target` can be reached before the shell claims
  `org.freedesktop.Notifications`.
- The notifier is only a prompt. It does not run migrations in the background.
- A session that is already open when another user updates is not re-checked;
  it picks the migrations up at its next login, or whenever that user runs
  `eoshell-migrate` or `eoshell update`.
- Direct pacman updates do not run `eoshell-hook post-update` unless the user
  explicitly runs that hook; without a package-update marker, the only pending
  state we can derive is missing per-user migration markers.

## Shell update indicator

The bar widget `eoshell.system-update` runs:

```bash
eoshell-update-available
```

`eoshell-update-available` checks the active Eoshell sources for updates:

- new upstream commits for the active dev-linked checkout
- `eoshell-dev`, when installed
- otherwise `eoshell`, when installed

The dev check fetches the checkout's configured upstream before comparing it
with `HEAD`. A failed fetch is quiet and falls back to the existing remote-
tracking state.

Exit codes:

- `0` — Eoshell updates are available; stdout is the update list.
- non-zero — no Eoshell updates are available; stdout says Eoshell is up to date.

The widget runs this check on shell startup and every six hours. Clicking the
update icon launches `eoshell-update` in a floating terminal.

## Channels and versions

Updates install whatever the active channel points at. `eoshell-channel-set
<stable|rc|edge|dev>` switches channels: the three package channels select
which pacman repo the mirrorlist points at (and swap between the `eoshell` and
`eoshell-dev` packages through a guard-allowed pacman run), while `dev` links
the runtime to a git checkout via the dev-link mechanism, after which
`eoshell update` fast-forwards that checkout instead of upgrading a package.
The refresh before that swap ignores `eoshell-dev` and `eoshell-settings-dev` on stable and rc, so an old build of them still listed in those repositories can't replace an edge machine's tree before the swap installs the release.
Channel switching runs the `pre-refresh-pacman` hook once, during its refresh
step, after the package config is re-synced and before the refresh transaction. It does not run if the switch fails earlier.

Every platform has its own pacman.conf and mirrorlist for each channel it offers (x86_64 and aarch64 stable, rc and edge; Apple Silicon too, below), and a channel change or install finalization copies them into place whole, the same way on every platform (`install/helpers/pacman.sh`); a channel change backs up the old pair first. x86_64's are `default/pacman/pacman-<channel>.conf` and `mirrorlist-<channel>`; Snapdragon and other aarch64 machines use `default/pacman/aarch64/`, the same files with Arch Linux ARM's repositories and Eoshell's mirror of them for that channel (`arm-mirror.eoshell.org`, `arm-rc-mirror.eoshell.org`, `arm-stable-mirror.eoshell.org`), Eoshell's repository ahead of Arch Linux ARM's, as x86_64 puts it ahead of Arch's (migration 1791403252 reorders existing machines the same way, and a refresh can then move a package Eoshell also publishes to Eoshell's build, downgrading it if that build is older); Apple Silicon uses `default/pacman/aarch64-apple/`, which puts Eoshell and Asahi ALARM ahead of Arch Linux ARM. Apple Silicon has stable, rc and edge templates (its rc and stable use `pkgs.eoshell.org/<channel>` and `arm-<channel>-mirror.eoshell.org`; Asahi ALARM has one repository for every channel); its packages reach rc by promotion from edge, and stable by promotion from rc. A channel change refuses a channel without both files for the platform before anything changes. On aarch64, `eoshell-channel-set` refuses to link a dev checkout without `bin/eoshell-hw-platform` and `install/helpers/pacman.sh`, whose own refresh would write the x86_64 templates. `eoshell-reinstall-pkgs` resets to the platform's default channel (`eoshell_pacman_default_channel`: stable, or edge on Apple Silicon) and installs its default packages; install finalization does the same when the install's channel has no templates for the platform.

There is no version file at runtime. `eoshell-version` derives the version from
`pacman -Q` on whichever package is installed, or reports `dev (<hash>)` for a
linked checkout, and `eoshell-version-channel` sniffs the mirrorlist and
pacman.conf to answer which channel is active.

## Update-related binaries

This inventory is intentionally opinionated. Some commands are useful as stable
leaf commands; others exist mostly because the old update flow accreted small
scripts.

| Binary | Current purpose | Keep? / Question |
| --- | --- | --- |
| `eoshell-update` | Public user command. Adds transcript logging, confirmation, snapshot, and restart checks around the locked, sleep-inhibited update pipeline. | **Keep.** This is the blessed entry point and orchestrates the update pipeline. |
| `eoshell-update-lock` | Hidden command wrapper that holds the per-user update lock while its child runs. | **Keep internal/hidden.** Isolates update concurrency and lock descriptor handling. |
| `eoshell-update-stay-awake` | Hidden helper that starts or stops update-owned sleep and idle inhibition, restoring only the state it changed. | **Keep internal/hidden.** Keeps inhibitor ownership and cleanup together. |
| `eoshell-update-status` | Hidden compatibility helper that clears the shell update indicator. `eoshell-update` clears it directly now; an update started by an older `eoshell-update` still calls this after its upgrade. | **Temporary.** Keep only for updates started before the change. |
| `eoshell-update-confirm` | Gum confirmation copy for `eoshell update`. | **Question.** Could be inlined into `eoshell-update`; separate file only helps keep copy isolated. |
| `eoshell-update-dev` | Fast-forwards the active dev-linked checkout from its configured upstream; no-ops for package-backed installs. | **Keep.** Runs before package updates so a checkout conflict stops the update before system mutation. |
| `eoshell-update-keyring` | Ensures Eoshell keyring and Arch keyring (and Arch Linux ARM keyring on aarch64, where installed) are current before the main transaction. | **Keep, but review.** It uses targeted `pacman -Sy` for keyring bootstrapping; acceptable for this special case but should remain tightly scoped. |
| `eoshell-update-system-pkgs` | Runs `eoshell-update-pacman -Syu --noconfirm` with `--overwrite '/usr/share/eoshell/*'`, capturing stderr to a report file; on failure it execs `eoshell-update-system-pkgs-when-conflicted`. | **Keep for now.** Small leaf command, clear/testable. |
| `eoshell-update-system-pkgs-when-conflicted` | Hidden conflict handler: quarantines unowned conflicting files under `/var/lib/eoshell/replaced`, retries the upgrade once, restores files the upgrade didn't claim, and hands package-vs-package conflicts to an interactive pacman run (never under `-y`). | **Keep internal/hidden.** Keeps conflict recovery out of the happy path. |
| `eoshell-update-pkg-prune` | Trims the pacman cache to two versions per package (`paccache -rk2`) before the snapshot, keeping the offline downgrade path while capping snapshot growth. | **Keep internal/hidden.** |
| `eoshell-update-requires-free-space` | Aborts the update below a 10 GiB free-space threshold on `/`; silently skipped when free space cannot be determined; `EOSHELL_UPDATE_FORCE=1` bypasses. | **Keep internal/hidden.** |
| `eoshell-migrate` | Public migration command. Waits for pacman, then runs all pending migrations for the current user. Supports `--pending`. | **Keep.** This replaces the discarded `eoshell-update-user-finalize` name and no longer needs `--force`. |
| `eoshell-update-pacman-guard` | ALPM pre-transaction guard that aborts direct `pacman -Syu` style upgrades unless Eoshell set `EOSHELL_UPDATE_PACMAN=1` or the user explicitly set `EOSHELL_ALLOW_DIRECT_PACMAN=1`. | **Keep internal/hidden.** This is what nudges users back to `eoshell update`. |
| `eoshell-update-pacman` | Hidden helper that runs a guard-approved pacman transaction as a PID 1 scope (`systemd-run --scope`) so a mid-transaction systemd reexec cannot kill it; runs pacman directly when not booted under systemd. | **Keep internal/hidden.** Single place that owns how Eoshell invokes pacman for system mutation. |
| `eoshell-migrate-notify` | Internal login-time notification helper. Uses `eoshell-migrate --pending` and shows a notification only when this user has pending migrations. | **Keep internal/hidden.** Clear name now that the public command is `eoshell-migrate`. |
| `eoshell-update-user-notify` | Hidden compatibility wrapper for `eoshell-migrate-notify`. | **Temporary.** Keep only for old callers. |
| `eoshell-update-available` | Update checker for the shell widget. The update itself clears the widget instead of rechecking. | **Keep.** Could eventually be renamed `eoshell-update-check`, but current name matches widget semantics. |
| `eoshell-update-aur-pkgs` | Updates AUR packages with `yay -Sua` if foreign packages exist and AUR is reachable. | **Question.** Eoshell is package-backed now, but users may still install AUR packages. Keep for now. |
| `eoshell-update-mise` | Runs `MISE_MINIMUM_RELEASE_AGE=0 mise up` for mise-managed tools — the override of mise's release-age cooldown is the point. | **Keep.** Mise-managed tools are intentionally part of the blessed update path. |
| `eoshell-update-orphan-pkgs` | Lists orphans and prompts before removal unless passed `-y`, as the update pipeline does; standalone noninteractive mode only reports. | **Keep for now.** Automates cleanup during updates and supports standalone review. |
| `eoshell-update-analyze-logs` | Scans `/tmp/eoshell-update.log` for known failure patterns, currently initramfs generation. | **Keep/expand.** Useful safety net; should grow only for high-signal checks. |
| `eoshell-update-boot` | Hidden helper that runs the platform's `update-verify` lifecycle operation through `eoshell-lifecycle-dispatch`, with `sudo` only when the platform implements it. | **Keep internal/hidden.** Keeps platform boot checks out of the pipeline and stubbable in tests. |
| `eoshell-update-restart` | Restarts components selected by `restart-*-required` markers, always restarts the shell, and prompts for reboot after kernel/Hyprland updates. Internal phase flags let the update finish sudo-capable restarts before user hooks and defer only the unprivileged reboot prompt. | **Keep.** Important final step; may eventually include service-restart checks. |
| `eoshell-update-firmware` | Manual firmware update command using fwupd. Not part of the normal update pipeline. | **Keep separate.** Firmware is not a routine system update step. |
| `eoshell-update-time` | Restarts `systemd-timesyncd`. | **Question.** Not really an update command. Consider renaming/moving under system/time maintenance. |

## Closed decisions

1. **Migrations run per-user from the update pipeline**
   - `eoshell update` runs `eoshell-migrate` after pacman finishes.
   - Package-time migration runners do not apply migrations inside pacman.
   - Every user has per-user migration markers, and migrations must be
     idempotent when they repair machine-wide state.

2. **Migration notification naming**
   - The real helper is `eoshell-migrate-notify`, started by
     `eoshell-migrate-notify.service`.
   - `eoshell-update-user-notify` remains only as a hidden compatibility wrapper.

3. **Update pipeline ownership**
   - `eoshell-update` owns the full update pipeline now.

4. **Mise remains in the blessed update path**
   - `eoshell-update-mise` intentionally runs as part of `eoshell update`.

5. **Orphan cleanup stays in the update path for now**
   - It is prompt-only and never removes packages noninteractively.

6. **Direct pacman user follow-up is based on actual migration state**
   - Direct `sudo pacman -Syu` no longer uses a fake user-update marker.
   - User notifications are shown only when `eoshell-migrate --pending` finds
     missing per-user migration state.

## Remaining concerns

1. **Pacman guard scope**
   - The guard detects direct pacman sysupgrade invocations and allows Eoshell
     commands that set `EOSHELL_UPDATE_PACMAN=1`.
   - We may regret blocking some legitimate package-manager frontends or
     maintenance flows. Keep an eye on what should be allowed versus redirected
     to `eoshell update`.

2. **Pacnew/pacsave handling is still missing**
   - Package-backed Eoshell should warn about or help process `.pacnew` and
     `.pacsave` files after updates.
