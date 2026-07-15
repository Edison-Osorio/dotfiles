#!/usr/bin/env bash

# Asegurar que nm-applet esté corriendo
if ! pgrep -x nm-applet > /dev/null; then
    nm-applet --indicator &
    sleep 1
fi

PID=$(pgrep -x nm-applet | head -1)

# Buscar el nombre D-Bus de nm-applet
SERVICE=$(dbus-send --session --print-reply \
    --dest=org.freedesktop.DBus \
    /org/freedesktop/DBus \
    org.freedesktop.DBus.ListNames 2>/dev/null \
    | grep -o "org.kde.StatusNotifierItem-${PID}-[0-9]*" | head -1)

if [[ -n "$SERVICE" ]]; then
    dbus-send --session \
        --dest="$SERVICE" \
        /StatusNotifierItem \
        org.kde.StatusNotifierItem.Activate \
        int32:0 int32:0 2>/dev/null
fi
