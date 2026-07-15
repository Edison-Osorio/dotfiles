#!/usr/bin/env bash
player=$(playerctl -l 2>/dev/null | while read -r p; do
  status=$(playerctl --player="$p" status 2>/dev/null)
  [[ "$status" == "Playing" ]] && echo "$p"
done | grep -i spotify | head -1)

[[ -z "$player" ]] && player=$(playerctl -l 2>/dev/null | while read -r p; do
  status=$(playerctl --player="$p" status 2>/dev/null)
  [[ "$status" == "Playing" ]] && echo "$p"
done | head -1)

[[ -z "$player" ]] && player=$(playerctl -l 2>/dev/null | head -1)
[[ -z "$player" ]] && echo '{"text":"","class":"stopped"}' && exit 0

status=$(playerctl --player="$player" status 2>/dev/null)
if [[ "$status" == "Playing" ]]; then
    echo '{"text":"⏸","class":"playing"}'
else
    echo '{"text":"▶","class":"paused"}'
fi
