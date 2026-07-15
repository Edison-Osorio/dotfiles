#!/usr/bin/env bash
BAT=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 2>/dev/null)

CAPACITY=$(grep -oP 'percentage:\s*\K[0-9]+' <<< "$BAT")
STATE=$(grep -oP 'state:\s*\K\S+' <<< "$BAT")
TIME_TO=$(grep -oP 'time to (empty|full):\s*\K.+' <<< "$BAT" | head -1)

case "$STATE" in
  charging)    ICON="󰂄"; LABEL="Cargando" ;;
  discharging) ICON="󰁾"; LABEL="Descargando" ;;
  fully-charged) ICON="󰁹"; LABEL="Carga completa" ;;
  *)           ICON="󰂑"; LABEL="$STATE" ;;
esac

BODY="$ICON  $CAPACITY%  •  $LABEL"
[[ -n "$TIME_TO" ]] && BODY="$BODY\n⏱ $TIME_TO"

notify-send "Batería" "$BODY" \
  --icon=battery \
  --urgency=low \
  --expire-time=4000
