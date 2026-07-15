#!/bin/bash
if hyprctl monitors | grep -q "DP-1"; then
    # Monitor externo activo: solo apagar pantalla del portátil, sin bloquear
    hyprctl keyword monitor "eDP-1,disable"
else
    # Solo portátil: bloquear y suspender
    loginctl lock-session
    systemctl suspend
fi
