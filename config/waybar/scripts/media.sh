#!/usr/bin/env bash
# Widget de música para Waybar via playerctl

# Preferir reproductor activo; entre varios, priorizar spotify
player=$(playerctl -l 2>/dev/null | while read p; do
  status=$(playerctl --player="$p" status 2>/dev/null)
  [[ "$status" == "Playing" ]] && echo "$p"
done | grep -i spotify | head -1)

# Si spotify no está reproduciendo, tomar cualquier reproductor activo
if [[ -z "$player" ]]; then
  player=$(playerctl -l 2>/dev/null | while read p; do
    status=$(playerctl --player="$p" status 2>/dev/null)
    [[ "$status" == "Playing" ]] && echo "$p"
  done | head -1)
fi

# Si nada está reproduciendo, tomar el primero disponible
if [[ -z "$player" ]]; then
  player=$(playerctl -l 2>/dev/null | grep -i spotify | head -1)
fi
if [[ -z "$player" ]]; then
  player=$(playerctl -l 2>/dev/null | head -1)
fi

if [ -z "$player" ]; then
    echo '{"text": "", "class": "stopped", "tooltip": "Sin reproductor"}'
    exit 0
fi

status=$(playerctl --player="$player" status 2>/dev/null)

if [ "$status" = "Stopped" ] || [ -z "$status" ]; then
    echo '{"text": "", "class": "stopped", "tooltip": "Detenido"}'
    exit 0
fi

artist=$(playerctl --player="$player" metadata artist 2>/dev/null | cut -c1-20)
title=$(playerctl --player="$player" metadata title 2>/dev/null | cut -c1-25)

if [ -z "$title" ]; then
    echo '{"text": "", "class": "stopped"}'
    exit 0
fi

if [ "$status" = "Playing" ]; then
    icon="󰎇"
    class="playing"
else
    icon="󰏤"
    class="paused"
fi

if [ -n "$artist" ]; then
    display="${icon}  ${artist} — ${title}"
    tooltip="${artist}\n${title}\n[${status}] — ${player}"
else
    display="${icon}  ${title}"
    tooltip="${title}\n[${status}] — ${player}"
fi

echo "{\"text\": \"${display}\", \"class\": \"${class}\", \"tooltip\": \"${tooltip}\"}"
