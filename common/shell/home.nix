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
    ./nvim/nvim.nix
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "qtwebengine-5.15.19"
      ];
    };
  };

  home.packages = lib.mkMerge [
    (with pkgs; [
      unzip
      usbutils
      gh
      ripgrep
      nixfmt-rfc-style
      # fancy-cat
      aider-chat-full
      qman
      git-my
      diff-so-fancy

      texliveFull
      texlivePackages.plantuml
      nix-search-cli
      mdcat
    ])
  ];

  home.file = {
    ".config/neofetch/config.conf".source = ./dotfiles/dot_config/neofetch/config;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
