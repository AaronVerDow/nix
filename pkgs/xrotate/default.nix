{ pkgs ? import <nixpkgs> {} }:

pkgs.writeShellApplication {
  name = "xrotate";
  runtimeInputs = with pkgs; [ bash xorg.xrandr xorg.xinput ];
  script = ./xrotate.sh;
}
