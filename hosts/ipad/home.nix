{ pkgs, ... }:

{
  imports = [
    ../../common/home.nix
    ../../common/x/home.nix
  ];
  home.packages = with pkgs; [
    (writeShellScriptBin "backlight" ''
      set -euo pipefail
      backlight="/sys/class/backlight/amdgpu_bl1"
      max=$( cat $backlight/max_brightness )
      echo $1 | awk -v max=$max '{printf "%.0f\n", ($1 / 100) * max}' | sudo tee $backlight/brightness
    '')

    (writeShellScriptBin "desk" ''
      set -euo pipefail
      ext=$(xrandr | grep '^HDMI.* connected' | awk '{print $1}' | head -n1 || true)
      [ -z "$ext" ] && exit 0
      xrandr --output "$ext" --mode 3440x1440 --primary --pos 0x0 \
             --output eDP --mode 1920x1200 --rotate inverted --pos 760x1440
      wallpaper_set
    '')

    (writeShellScriptBin "undock" ''
      set -euo pipefail
      ext=$(xrandr | grep '\bconnected' | grep -v '^eDP' | awk '{print $1}' | head -n1 || true)
      if [ -n "$ext" ]; then
        xrandr --output "$ext" --off
      fi
      xrandr --output eDP --auto --rotate normal --pos 0x0
      wallpaper_set
    '')

  ];
}
