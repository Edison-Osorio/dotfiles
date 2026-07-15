#!/bin/bash

WALLPAPER="$HOME/.local/share/wallpapers/wallpaper.png"

set_wallpaper() {
    sleep 0.5
    swww img --outputs eDP-1 "$WALLPAPER" 2>/dev/null
    swww img --outputs DP-1  "$WALLPAPER" 2>/dev/null
}

CHOICE=$(printf \
"Extendido: Laptop izquierda\nExtendido: Laptop derecha\nExtendido: Externo arriba\nSolo Laptop\nSolo Monitor Externo\nEspejo (Mirror)\nRefrescar fondo\nConfiguración avanzada" \
| wofi --show dmenu --prompt "  Monitores" --width 380 --height 310 --no-actions)

case "$CHOICE" in
    "Extendido: Laptop izquierda")
        hyprctl keyword monitor "eDP-1,1920x1080@60.05,0x0,1.0"
        hyprctl keyword monitor "DP-1,2560x1440@200.0,1920x0,1.0"
        set_wallpaper
        ;;
    "Extendido: Laptop derecha")
        hyprctl keyword monitor "DP-1,2560x1440@200.0,0x0,1.0"
        hyprctl keyword monitor "eDP-1,1920x1080@60.05,2560x0,1.0"
        set_wallpaper
        ;;
    "Extendido: Externo arriba")
        hyprctl keyword monitor "DP-1,2560x1440@200.0,0x0,1.0"
        hyprctl keyword monitor "eDP-1,1920x1080@60.05,0x1440,1.0"
        set_wallpaper
        ;;
    "Solo Laptop")
        hyprctl keyword monitor "DP-1,disable"
        hyprctl keyword monitor "eDP-1,1920x1080@60.05,0x0,1.0"
        set_wallpaper
        ;;
    "Solo Monitor Externo")
        hyprctl keyword monitor "eDP-1,disable"
        hyprctl keyword monitor "DP-1,2560x1440@200.0,0x0,1.0"
        set_wallpaper
        ;;
    "Espejo (Mirror)")
        hyprctl keyword monitor "eDP-1,1920x1080@60.05,0x0,1.0"
        hyprctl keyword monitor "DP-1,1920x1080@60,0x0,1.0,mirror,eDP-1"
        set_wallpaper
        ;;
    "Refrescar fondo")
        set_wallpaper
        ;;
    "Configuración avanzada")
        nwg-displays &
        ;;
esac
