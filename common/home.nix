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
    ./nvim.nix
    ./prose/prose.nix
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = "averdow";
    homeDirectory = "/home/averdow";
  };

  home.packages = lib.mkMerge [ (with pkgs; [
    unzip
    usbutils

    texliveFull
    nix-search-cli
    mdcat

    (writeShellScriptBin "my_ping" ''
      gateway=$( ip route | grep default | awk '{ print $3}' )
      sudo ${pkgs.liboping}/bin/noping $gateway modem public
    '')

    (writeShellScriptBin "pkg" ''
      nom shell nixpkgs#$1
    '')
  ])];

  programs.home-manager.enable = true;

  programs.git = {
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    userName = "Aaron VerDow";
    userEmail = "aaron@verdow.com";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";


  # hacky solution until I find a proper home for this, typically goes in /etc/ so root is impacted as well
  home.file.".bash.bashrc".source = ./dotfiles/dot_bash.bashrc.sh;
  # should be in /etc/DIR_COLORS ?
  home.file.".dir_colors".source = ./dotfiles/dot_dir_colors.sh;
  home.file.".bashrc".source = ./dotfiles/dot_bashrc.sh;
  home.file.".config/neofetch/config.conf".source = ./dotfiles/dot_config/neofetch/config;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
