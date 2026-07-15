#!/usr/bin/env bash

CONSERVATION=/sys/bus/platform/devices/VPC2004:00/conservation_mode
CAPACITY=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
STATUS=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
CURRENT_CONS=$(cat "$CONSERVATION" 2>/dev/null)
BATTERY_MODE=$(cat ~/.config/battery-mode 2>/dev/null || echo "limit")

FLAG_LOW=/tmp/.battery-notified-low
FLAG_LIMIT=/tmp/.battery-limit-active

# ── Aplica el modo guardado al arrancar (si conservation_mode no coincide) ──
if [[ "$BATTERY_MODE" == "full" && "$CURRENT_CONS" == "1" && ! -f "$FLAG_LIMIT" ]]; then
  sudo /usr/local/bin/battery-conservation 0
fi

# ── Límite software al 80% (solo en modo escritorio) ────────────
if [[ "$BATTERY_MODE" == "limit" ]]; then
  if [[ "$STATUS" == "Charging" && "$CAPACITY" -ge 80 ]]; then
    if [[ "$CURRENT_CONS" == "0" ]]; then
      sudo /usr/local/bin/battery-conservation 1
      touch "$FLAG_LIMIT"
      notify-send "Batería" "󰂁 Límite al 80% alcanzado — carga pausada" \
        -u low -t 4000
    fi
  elif [[ "$STATUS" == "Charging" && "$CAPACITY" -le 75 ]]; then
    if [[ -f "$FLAG_LIMIT" && "$CURRENT_CONS" == "1" ]]; then
      sudo /usr/local/bin/battery-conservation 0
      rm -f "$FLAG_LIMIT"
    fi
  fi
fi

# ── Alerta batería baja al 20% ──────────────────────────────────
if [[ "$STATUS" == "Discharging" && "$CAPACITY" -le 20 ]]; then
  if [[ ! -f "$FLAG_LOW" ]]; then
    notify-send "Batería baja" "󰁻 ${CAPACITY}% — Conecta el cargador" \
      -u critical -t 0
    touch "$FLAG_LOW"
  fi
else
  rm -f "$FLAG_LOW"
fi
