{ pkgs, ... }:

{
  imports = [ ../../common/home.nix ];
  home.packages = with pkgs; [ 
    # gui programs
    (writeShellScriptBin "backlight" ''
      set -euo pipefail
      backlight="/sys/class/backlight/amdgpu_bl1"
      max=$( cat $backlight/max_brightness )
      echo $1 | awk -v max=$max '{printf "%.0f\n", ($1 / 100) * max}' | sudo tee $backlight/brightness
    '')
  ];
}
