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
      xrandr --output eDP --auto --below DisplayPort-0 --output DisplayPort-0 --mode 3440x1440
      set_wallpaper
    '')

    (writeShellScriptBin "undock" ''
      xrandr --output eDP --auto --output DisplayPort-0 --off
      set_wallpaper
    '')

  ];
}
