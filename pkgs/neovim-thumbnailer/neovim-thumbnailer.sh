set -euo pipefail
set -x

export LIBGL_ALWAYS_SOFTWARE=1
export MESA_GL_VERSION_OVERRIDE=3.1
export FONTCONFIG_PATH=${pkgs.fontconfig}/etc/fonts

FILE="$1"
OUTPUT="$2"
SIZE="''${3:-256}"
XVFB_DISPLAY=:99
SCREEN_WIDTH=1024
SCREEN_HEIGHT=1024
FONT_SIZE=10

${pkgs.xorg.xvfb}/bin/Xvfb $XVFB_DISPLAY -screen 0 "''${SCREEN_WIDTH}x''${SCREEN_HEIGHT}x24" &
XVFB_PID=$!
export DISPLAY=$XVFB_DISPLAY

TEMP=$(mktemp)
cleanup() {
  kill $KITTY_PID || true
  kill $XVFB_PID || true
  rm $TEMP
}
trap cleanup EXIT

${pkgs.kitty}/bin/kitty --start-as maximized --override font_size=$FONT_SIZE ${pkgs.neovim}/bin/nvim "$FILE" &
KITTY_PID=$!

WINDOW_ID=""
for i in {1..30}; do
    WINDOW_ID=$(${pkgs.xorg.xwininfo}/bin/xwininfo -root -tree | grep -m1 "kitty" | awk '{print $1}' || true)
    if [[ -n "$WINDOW_ID" ]]; then break; fi
    sleep 0.2
done

sleep 1

${pkgs.xorg.xwd}/bin/xwd -id "$WINDOW_ID" -out "$TEMP"
${pkgs.imagemagick}/bin/convert "$TEMP" -thumbnail "$SIZE" "$OUTPUT"
