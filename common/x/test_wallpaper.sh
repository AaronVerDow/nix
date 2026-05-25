#!/usr/bin/env bash
set -euo pipefail
set -x

killall esshader

nohup esshader --fullscreen --source ~/.config/wallpaper.glsl &>/dev/null &

# Get all connected outputs and spawn esshader on each
xrandr --query | grep connected | while read -r line; do
  output=$(echo "$line" | awk '{print $1}')
  dims=$(echo "$line" | grep -oP '\d+\sx\s\d+')
  width=$(echo "$dims" | awk -F'x' '{print $1}')
  height=$(echo "$dims" | awk -F'x' '{print $2}')
  [ -n "$width" ] && nohup esshader --width $width --height $height --source ~/.config/wallpaper.glsl &>/dev/null &
done
