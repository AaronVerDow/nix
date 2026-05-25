#!/usr/bin/env bash
set -euo pipefail
set -x

killall esshader || true

# Get all connected outputs and spawn esshader on each
xrandr --query | grep connected | while read -r line; do
  output=$(echo "$line" | awk '{print $1}')
  dims=$(echo "$line" | grep -oE '[0-9]+x[0-9]+')
  width=$(echo "$dims" | awk -F'x' '{print $1}')
  height=$(echo "$dims" | awk -F'x' '{print $2}')
  [ -n "$width" ] && nohup esshader --width $width --height $height --source ~/.config/wallpaper.glsl &>/dev/null &
done
