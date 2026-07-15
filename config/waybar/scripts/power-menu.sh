#!/usr/bin/env bash

CONSERVATION=/sys/bus/platform/devices/VPC2004:00/conservation_mode
PROFILE_FILE=/sys/firmware/acpi/platform_profile
BATTERY_MODE_FILE=~/.config/battery-mode

set_profile_dbus() {
  gdbus call --system \
    --dest net.hadess.PowerProfiles \
    --object-path /net/hadess/PowerProfiles \
    --method org.freedesktop.DBus.Properties.Set \
    "net.hadess.PowerProfiles" "ActiveProfile" \
    "<'$1'>" 2>/dev/null
}

current_profile=$(cat "$PROFILE_FILE" 2>/dev/null)
battery_mode=$(cat "$BATTERY_MODE_FILE" 2>/dev/null || echo "limit")

perf_mark=""; bal_mark=""; low_mark=""
case "$current_profile" in
  performance) perf_mark=" ✓" ;;
  balanced)    bal_mark=" ✓" ;;
  low-power)   low_mark=" ✓" ;;
esac

if [[ "$battery_mode" == "limit" ]]; then
  bat_limit_mark=" ✓"
  bat_full_mark=""
else
  bat_limit_mark=""
  bat_full_mark=" ✓"
fi

MENU=$(printf \
"⚡  Rendimiento${perf_mark}\n\
⚖  Balanceado${bal_mark}\n\
🍃  Ahorro de energía${low_mark}\n\
───────────────────\n\
󰂁  Límite 80%%${bat_limit_mark}\n\
󰁹  Carga completa${bat_full_mark}" \
  | wofi --dmenu \
         --prompt "Energía" \
         --width 290 \
         --height 270 \
         --no-actions \
         --insensitive \
         --define=single-click=true \
         --define=sort-order=default \
         --style ~/.config/wofi/power-style.css 2>/dev/null)

[[ -z "$MENU" ]] && exit 0

if [[ "$MENU" == *"Rendimiento"* ]]; then
  set_profile_dbus "performance"
  notify-send "Perfil de energía" "⚡ Rendimiento activado" -u low -t 2000

elif [[ "$MENU" == *"Balanceado"* ]]; then
  set_profile_dbus "balanced"
  notify-send "Perfil de energía" "⚖ Balanceado activado" -u low -t 2000

elif [[ "$MENU" == *"Ahorro"* ]]; then
  set_profile_dbus "power-saver"
  notify-send "Perfil de energía" "🍃 Ahorro de energía activado" -u low -t 2000

elif [[ "$MENU" == *"Límite 80"* ]]; then
  echo "limit" > ~/.config/battery-mode
  sudo /usr/local/bin/battery-conservation 1
  notify-send "Batería" "󰂁 Límite 80%% activado" -u low -t 2000

elif [[ "$MENU" == *"Carga completa"* ]]; then
  echo "full" > ~/.config/battery-mode
  sudo /usr/local/bin/battery-conservation 0
  notify-send "Batería" "󰁹 Carga completa al 100%%" -u low -t 2000
fi
