# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:

{
  home.packages = lib.mkMerge [
    (with pkgs; [
      # Development Tools
      jetbrains.idea-ultimate
      qtcreator

      # Creative & Design Applications
      blender # 3D modeling and animation
      drawing # Simple drawing application
      gimp # Image manipulation
      inkscape # Vector graphics editor

      unstable.via # Keyboard configuration
    ])
  ];
}
