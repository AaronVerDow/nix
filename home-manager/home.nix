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

let
  awesomeWmWidgets = pkgs.fetchFromGitHub {
    owner = "streetturtle";
    repo = "awesome-wm-widgets";
    rev = "df6bc4a260158fdc6e2678f1bb281f442d7887ac";
    sha256 = "sha256-IXV4YxG1hIq/LCurgbR1jEcwljRxxyVvwbEhrcJhlAk=";
  };
in
{
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  home = {
    username = "averdow";
    homeDirectory = "/home/averdow";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [ 
    # gui programs
    firefox
    discord
    openscad
    inkscape
    gimp
    kitty
    libreoffice

    # X customization
    rofi # pop up launcher
    nitrogen # set desktop background
    xcompmgr
    arc-icon-theme # battery widget
    acpi # battery widget

    # utilities
    scrot # screenshot utility
    pcmanfm
    pavucontrol
    fusuma # touchscreen gestures
    xclip
  ];

  # Enable home-manager and git
  programs.home-manager.enable = true;

  programs.git = {
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    userName = "Aaron VerDow";
    userEmail = "aaron@verdow.com";
  };


  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.file.".bashrc".source = ./dotfiles/dot_bashrc;
  home.file.".config/awesome/rc.lua".source = ./dotfiles/dot_config/awesome/rc.lua;
  home.file.".config/fusuma/config.yml".source = ./dotfiles/dot_config/fusuma/config.yml;
  home.file.".config/neofetch/config".source = ./dotfiles/dot_config/neofetch/config;
  home.file.".config/rofi/config.rasi".source = ./dotfiles/dot_config/rofi/config.rasi;
  home.file.".config/awesome/awesome-wm-widgets".source = awesomeWmWidgets;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
