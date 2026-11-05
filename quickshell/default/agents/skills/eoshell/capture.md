# Capture and Sharing

Read this before taking screenshots or screen recordings, extracting text from
the screen, or sharing files with other machines.

## Screenshots

```bash
eoshell screenshot                            # Interactive smart-region flow
eoshell capture screenshot region             # Select a region
eoshell capture screenshot windows            # Pick a window
eoshell capture screenshot fullscreen save    # Full screen, straight to disk (no editor)
eoshell capture screenshot scroll             # Capture and stitch a scrolling region
eoshell screenshot --editor=overlay           # Opt into annotation before output
```

The first argument picks the Omasnap mode (`smart|region|windows|fullscreen|scroll`). By default, a capture saves to disk, copies to the clipboard, and shows a notification with the shot's thumbnail and Open and Edit buttons. Use its Edit button to annotate, or pass `--editor=overlay` or `--editor=window` to edit before output. A second argument of `copy` or `save` sends the screenshot straight to that destination. Saved screenshots land in `~/Pictures/Screenshots` by default (override with `OMASNAP_SCREENSHOT_DIR`; the legacy `EOSHELL_SCREENSHOT_DIR` is also honored by the Eoshell command). Set `[output] autosave = false` in `~/.config/omasnap/omasnap.conf` to disable automatic saving; captures are then only copied and shown in a 10-second preview.

## Screen Recording

```bash
eoshell screenrecord --fullscreen             # Start recording the full screen
# ...exercise whatever you want on film...
eoshell screenrecord --stop-recording         # Stop; prints the saved path
```

Optional flags: `--with-desktop-audio`, `--with-microphone-audio`,
`--with-webcam` (plus `--webcam-device=` and `--webcam-size=`), and
`--resolution=<size>`. Without `--fullscreen` a region picker opens first.
Recordings land in the configured Videos directory (override with
`EOSHELL_SCREENRECORD_DIR`). Resize a live webcam overlay with
`eoshell capture webcam resize <smaller|larger|reset|small|medium|large>`.

If recording fails to start, rerun with `EOSHELL_SCREENRECORD_DEBUG=true` to
collect a log at `$XDG_RUNTIME_DIR/eoshell-screenrecord.log` (or `${XDG_STATE_HOME:-$HOME/.local/state}/eoshell/eoshell-screenrecord.log` without a session runtime directory) worth attaching to a bug
report.

## Text Capture (OCR)

```bash
eoshell capture text    # Select a region; extracted text goes to the clipboard
```

## Sharing Files

```bash
eoshell share clipboard               # Share the clipboard via LocalSend
eoshell share file <path...>          # Share files with nearby devices
eoshell share folder <path>           # Share a folder

eoshell tailscale send <machine> <file...>    # Taildrop to a tailnet machine
eoshell tailscale receive [directory]         # Save incoming Taildrop files
```

Shrink large captures before sharing them:

```bash
eoshell transcode <input> [format] [resolution]   # Re-encode pictures/videos for sharing
```
