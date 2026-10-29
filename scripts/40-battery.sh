#!/usr/bin/env bash
# Permite al grupo wheel cambiar el límite de carga (Lenovo, charge_types) sin sudo.
# La elección se guarda en ~/.config/battery-limit y se aplica al iniciar Hyprland.
# Ejecutar con: sudo bash 40-battery.sh
set -euo pipefail
systemctl disable --now battery-limit.service 2>/dev/null || true
rm -f /etc/systemd/system/battery-limit.service
systemctl daemon-reload
cat > /etc/udev/rules.d/99-battery-limit.rules <<'RULE'
SUBSYSTEM=="power_supply", KERNEL=="BAT0", RUN+="/bin/sh -c 'chgrp wheel /sys%p/charge_types; chmod g+w /sys%p/charge_types'"
RULE
udevadm control --reload
udevadm trigger --subsystem-match=power_supply --action=change
sleep 1
ls -l /sys/class/power_supply/BAT0/charge_types
