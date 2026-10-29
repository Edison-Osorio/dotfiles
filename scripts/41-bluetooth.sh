#!/usr/bin/env bash
# BlueZ enciende el adaptador en cada arranque (AutoEnable=true por defecto).
# Lo desactiva para respetar el último estado, que guarda bluetooth-power.
# Ejecutar con: sudo bash 41-bluetooth.sh
set -euo pipefail
f=/etc/bluetooth/main.conf
if grep -q '^AutoEnable=' "$f"; then sed -i 's/^AutoEnable=.*/AutoEnable=false/' "$f"
else sed -i 's/^#AutoEnable=true/AutoEnable=false/' "$f"; fi
grep -n '^AutoEnable' "$f"
systemctl restart bluetooth
