#!/usr/bin/env bash

player=$(playerctl -l 2>/dev/null | head -1)

if [[ -z "$player" ]]; then
    notify-send "Música" "No hay reproductor activo" -u low -t 2000
    exit 0
fi

status=$(playerctl --player="$player" status 2>/dev/null)
artist=$(playerctl --player="$player" metadata artist 2>/dev/null)
title=$(playerctl --player="$player" metadata title 2>/dev/null)

if [[ "$status" == "Playing" ]]; then
    play_mark="⏸  Pausar"
else
    play_mark="▶  Reproducir"
fi

# Título actual como primera línea decorativa
if [[ -n "$title" ]]; then
    header="🎵  ${artist:+$artist — }${title}"
    header="${header:0:40}"
else
    header="🎵  Sin pista"
fi

MENU=$(printf "%s\n───────────────────\n⏮  Anterior\n%s\n⏭  Siguiente\n───────────────────\n🔀  Aleatorio\n🔁  Repetir" \
    "$header" "$play_mark" \
    | wofi --dmenu \
           --prompt "Reproductor" \
           --width 300 \
           --height 260 \
           --no-actions \
           --define=sort-order=default \
           --style ~/.config/wofi/power-style.css 2>/dev/null)

[[ -z "$MENU" ]] && exit 0

if [[ "$MENU" == *"Anterior"* ]]; then
    playerctl --player="$player" previous
elif [[ "$MENU" == *"Pausar"* ]] || [[ "$MENU" == *"Reproducir"* ]]; then
    playerctl --player="$player" play-pause
elif [[ "$MENU" == *"Siguiente"* ]]; then
    playerctl --player="$player" next
elif [[ "$MENU" == *"Aleatorio"* ]]; then
    playerctl --player="$player" shuffle toggle
    state=$(playerctl --player="$player" shuffle 2>/dev/null)
    notify-send "Música" "Aleatorio: $state" -u low -t 1500
elif [[ "$MENU" == *"Repetir"* ]]; then
    playerctl --player="$player" loop track
    notify-send "Música" "Repetir pista activado" -u low -t 1500
fi
