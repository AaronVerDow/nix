{ pkgs ? import <nixpkgs> {} }:

let
  scriptContent = builtins.readFile ./xrotate.sh;
in
pkgs.writeShellApplication {
  name = "xrotate";
  runtimeInputs = with pkgs; [ bash xorg.xrandr xorg.xinput awesome ];
  text = scriptContent;
}
