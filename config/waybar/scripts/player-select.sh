#!/usr/bin/env bash
# Devuelve el reproductor a controlar.
# Si hay varios reproduciendo simultáneamente, abre wofi para elegir.

PLAYERS=$(playerctl -l 2>/dev/null)
[[ -z "$PLAYERS" ]] && exit 1

PLAYING=$(echo "$PLAYERS" | while read -r p; do
  status=$(playerctl --player="$p" status 2>/dev/null)
  [[ "$status" == "Playing" ]] && echo "$p"
done)

COUNT=$(echo "$PLAYING" | grep -c '\S' 2>/dev/null || echo 0)

if [[ "$COUNT" -gt 1 ]]; then
  LABELS=$(echo "$PLAYING" | sed \
    -e 's/spotify[^ ]*/🎵  Spotify/' \
    -e 's/firefox[^ ]*/🦊  Firefox/' \
    -e 's/chromium[^ ]*/🌐  Chromium/' \
    -e 's/brave[^ ]*/🦁  Brave/')

  SELECTED_LABEL=$(echo "$LABELS" | wofi --dmenu \
       --prompt "Controlar" \
       --width 240 \
       --height 180 \
       --no-actions \
       --define=sort-order=default \
       --style ~/.config/wofi/power-style.css 2>/dev/null)

  [[ -z "$SELECTED_LABEL" ]] && exit 1

  # Mapear etiqueta de vuelta al nombre real
  if echo "$SELECTED_LABEL" | grep -qi "spotify";  then echo "$PLAYING" | grep -i spotify | head -1
  elif echo "$SELECTED_LABEL" | grep -qi "firefox"; then echo "$PLAYING" | grep -i firefox | head -1
  elif echo "$SELECTED_LABEL" | grep -qi "chromium";then echo "$PLAYING" | grep -i chromium | head -1
  elif echo "$SELECTED_LABEL" | grep -qi "brave";   then echo "$PLAYING" | grep -i brave | head -1
  else echo "$PLAYING" | head -1
  fi

elif [[ "$COUNT" -eq 1 ]]; then
  echo "$PLAYING"
else
  # Ninguno reproduciendo: preferir spotify, si no el primero
  echo "$PLAYERS" | grep -i spotify | head -1 || echo "$PLAYERS" | head -1
fi
