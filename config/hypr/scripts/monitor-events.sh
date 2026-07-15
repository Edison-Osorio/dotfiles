#!/bin/bash

WALLPAPER="$HOME/.local/share/wallpapers/wallpaper.png"

set_wallpaper_all() {
    sleep 0.5
    swww img --outputs eDP-1 "$WALLPAPER" 2>/dev/null
    swww img --outputs DP-1  "$WALLPAPER" 2>/dev/null
}

handle_event() {
    case "$1" in
        monitorremoved\>\>DP-1*)
            hyprctl keyword monitor "eDP-1,1920x1080@60.05,0x0,1.0"
            sleep 0.5
            swww img --outputs eDP-1 "$WALLPAPER" 2>/dev/null
            ;;
        monitoradded\>\>DP-1*)
            sleep 1
            hyprctl keyword monitor "eDP-1,1920x1080@60.05,0x0,1.0"
            hyprctl keyword monitor "DP-1,2560x1440@200.0,1920x0,1.0"
            set_wallpaper_all
            ;;
    esac
}

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

socat - "UNIX-CONNECT:$SOCKET" | while IFS= read -r line; do
    handle_event "$line"
done
