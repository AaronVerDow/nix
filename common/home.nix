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

  home.packages = lib.mkMerge [
    (with pkgs; [
      unzip
      usbutils
      # fancy-cat
      gh
      ripgrep
      nixfmt-rfc-style
      my_fancy-cat
      aider-chat-full
      qman

      texliveFull
      nix-search-cli
      mdcat

      (writeShellScriptBin "my_ping" ''
        gateway=$( ip route | grep default | awk '{ print $3}' )
        sudo ${pkgs.liboping}/bin/noping $gateway modem public
      '')

      (writeShellScriptBin "pkg" ''
        nom shell nixpkgs#$1 || nix-search $1
      '')

      (writeShellScriptBin "eternal" (builtins.readFile ./dotfiles/bin/eternal.sh))

    ])
  ];

  programs.home-manager.enable = true;

  programs.git = {
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    userName = "Aaron VerDow";
    userEmail = "aaron@verdow.com";
    extraConfig = {
      pager.branch = false;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.file = {
    # hacky solution until I find a proper home for this, typically goes in /etc/ so root is impacted as well
    ".bash.bashrc".source = ./dotfiles/dot_bash.bashrc.sh;
    # should be in /etc/DIR_COLORS ?
    ".dir_colors".source = ./dotfiles/dot_dir_colors.sh;
    ".bashrc".source = ./dotfiles/dot_bashrc.sh;
    ".bash_profile".source = ./dotfiles/dot_bash_profile.sh;
    ".config/neofetch/config.conf".source = ./dotfiles/dot_config/neofetch/config;
    ".config/nixpkgs/config.nix".text = ''
      { allowUnfree = true; }
    '';
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
