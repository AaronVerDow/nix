{ pkgs, ... }:

{
  imports = [ ../../common/home.nix ];
  home.packages = with pkgs; [
    (writeShellScriptBin "backlight" ''
      set -euo pipefail
      backlight="/sys/class/backlight/amdgpu_bl1"
      max=$( cat $backlight/max_brightness )
      echo $1 | awk -v max=$max '{printf "%.0f\n", ($1 / 100) * max}' | sudo tee $backlight/brightness
    '')

    (writeShellScriptBin "desk" ''
      mon=$(xrandr | grep '\bconnected' | grep -m 1 -v primary | awk '{print $1}')
      xrandr --output eDP --auto --below "$mon" --output "$mon" --mode 3440x1440
      set_wallpaper
    '')

    (writeShellScriptBin "undock" ''
      mon=$(xrandr | grep '\bconnected' | grep -m 1 -v primary | awk '{print $1}')
      xrandr --output eDP --auto --output "$mon" --off
      set_wallpaper
    '')

  ];
}
