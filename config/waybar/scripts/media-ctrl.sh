#!/usr/bin/env bash
# Uso: media-ctrl.sh [previous|play-pause|next]
ACTION="${1:-play-pause}"
player=$(~/.config/waybar/scripts/player-select.sh)
[[ -z "$player" ]] && exit 0
playerctl --player="$player" "$ACTION"
