#!/usr/bin/env bash
set -exuo pipefail

# Check if calculator window exists
if xdotool search --name "Epsilon" > /dev/null; then
  # Get window ID
  WINDOW_ID=$(xdotool search --name "Epsilon")
  # Toggle window visibility using xdotool
  if xwininfo -id "$WINDOW_ID" | grep -q "Map State: IsViewable"; then
    xdotool windowminimize "$WINDOW_ID"
  else
    xdotool windowmap "$WINDOW_ID"
    xdotool windowactivate "$WINDOW_ID"
  fi
else
  # Launch calculator if not running
  epsilon &
fi 
