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
      trusted-users = [
        "root"
        "averdow"
      ];
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

  security.sudo.extraRules = [
    {
      users = ["averdow"];
      commands = [ {
        command = "${pkgs.liboping}/bin/noping";
        options = ["NOPASSWD"];
      } ];
    }
  ];

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
    gdu
  ];

  networking.networkmanager = {
    enable = true;
    wifi.powersave = false; # helps with barrier and mouse jumps?
  };

  # allow access for barrier
  networking.firewall.allowedTCPPorts = [ 24800 ];

  time.timeZone = "America/Chicago";

  # Added for WGU D288 final
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };

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

  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true; # recommended for audio

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;
  hardware.graphics.enable = true;
  hardware.keyboard.qmk.enable = true;

  environment.sessionVariables = {
    MOZ_USE_XINPUT2 = "1"; # touchscreen support for firefox
    FLAKE = "/home/averdow/git/nix"; # used by nix helper
    MANPAGER="nvim +Man!";
    MANWIDTH=999;
  };

  services.udev.packages = with pkgs; [
    unstable.via
  ];
  # Keychron isn't currenlty included by via
  services.udev.extraRules = ''
    # K9 Pro
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0290", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    # K7 Pro
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0270", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    # Kanata
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
  '';

  # Kanata requirements
  boot.kernelModules = [ "uinput" ];
  hardware.uinput.enable = true;
  users.groups.uinput = { };
  systemd.services.kanata-internalKeyboard.serviceConfig = {
    SupplementaryGroups = [
      "input"
      "uinput"
    ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
