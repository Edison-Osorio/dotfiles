#!/bin/bash
# Reactiva la pantalla del laptop y restaura el fondo
hyprctl keyword monitor "eDP-1,1920x1080@60.05,2290x1440,1.0"
sleep 0.5
swww img --outputs eDP-1 ~/.local/share/wallpapers/wallpaper.png
