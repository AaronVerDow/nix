# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
      auto-optimise-store = true;
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    gc.automatic = true;
    gc.dates = "daily";
    gc.options = "--delete-older-than +5";
  };

  users.users = {
    averdow = {
      initialPassword = "correcthorsebatterystaple";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
      ];
      extraGroups = [
        "networkmanager"
        "wheel"
        "adm"
        "input"
        "audio"
        "docker"
        "dialout"
      ];
      packages = with pkgs; [
        neofetch
        neovim
        nodejs # for neovim
        gcc # makes neovim plugins happy
        vimpager
        btop
        git
        ranger
        tldr
        lolcat
        direnv
        fd
        killall
        unzip
        onefetch
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    nix-output-monitor # nom upgrades nix with prettier output
    nvd # diff derevations
    nh # uses packages above for os builds
    liboping
    kitty
  ];

  networking.networkmanager = {
    enable = true;
    wifi.powersave = false; # helps with barrier and mouse jumps?
  };

  # allow access for barrier
  networking.firewall.allowedTCPPorts = [ 24800 ];

  time.timeZone = "America/Chicago";

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
    };
  };

 services.logind.extraConfig = ''
    # don’t shutdown when power button is short-pressed
    HandlePowerKey="ignore";
  '';

  programs.steam.enable = true;
  services.touchegg.enable = true;
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.cups-brother-hll2340dw ];

  services.xserver.enable = true;

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.windowManager.awesome.enable = true;
  programs.hyprland.enable = true;

  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;
  nixpkgs.config.pulseaudio = true;
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

  hardware.opengl.enable = true;

  environment.sessionVariables = {
    MOZ_USE_XINPUT2 = "1"; # touchscreen support for firefox
    FLAKE = "/home/averdow/git/nix"; # used by nix helper
    MANPAGER="nvim +Man!";
    MANWIDTH=999;
  };

  services.udev.packages = with pkgs; [
    via
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
