set -euo pipefail
set -x

FILE="$1"
OUTPUT="$2"
SIZE="${3:-256}"
XVFB_DISPLAY=:99
SCREEN_WIDTH=1024
SCREEN_HEIGHT=1024

Xvfb $XVFB_DISPLAY -screen 0 "${SCREEN_WIDTH}x${SCREEN_HEIGHT}x24" &
XVFB_PID=$!
export DISPLAY=$XVFB_DISPLAY

TEMP=$(mktemp)
cleanup() {
  kill $XTERM_PID || true
  kill $XVFB_PID || true
  rm "$TEMP"
}
trap cleanup EXIT

xterm -geometry "90x40" -fg white -bg black -fa "Monospace:style=Bold" -e nvim -u NONE -c "syntax on" -c "colorscheme humanoid" "$FILE" &
XTERM_PID=$!

WINDOW_ID=""
for i in {1..30}; do
    WINDOW_ID=$(xwininfo -root -tree | grep -m1 "XTerm" | awk '{print $1}' || true)
    sleep 0.2
    [ -n "$WINDOW_ID" ] && break
done

xwd -id "$WINDOW_ID" -out "$TEMP"
magick xwd:"$TEMP" -thumbnail "$SIZE" "$OUTPUT"
