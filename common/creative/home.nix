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
  imports = [
    ./prose/prose.nix
  ];

  home.packages = lib.mkMerge [
    (with pkgs; [
      # Creative & Design Applications
      my_openscad # Programmatic CAD modeling
      openscad-post-processor

      gimp

      mlterm # Alternative terminal

      unstable.restream
      restream-desktop # Desktop entry for restream preview

      # Fonts & Themes
      courier-prime
      libertine
      merriweather
      iosevka
      b612
      victor-mono
      google-fonts

      (nix-run-desktop.launcher {
        nativeBuildInputs = [ blender ];
        copy_icons = false;
      })
      (nix-run-desktop.launcher {
        nativeBuildInputs = [ inkscape ];
        copy_icons = false;
      })
      (nix-run-desktop.launcher {
        nativeBuildInputs = [ freecad ];
        copy_icons = false;
      })
      (nix-run-desktop.launcher {
        nativeBuildInputs = [ obs-studio ];
        copy_icons = false;
      })
      (nix-run-desktop.launcher {
        nativeBuildInputs = [ drawing ];
      })
      (nix-run-desktop.launcher {
        nativeBuildInputs = [ openshot-qt ];
        copy_icons = false;
      })
    ])
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
