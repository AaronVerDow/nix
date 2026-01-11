# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
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
    inputs.home-manager.nixosModules.home-manager
  ];

  i18n.defaultLocale = "en_US.UTF-8";

 boot.loader.limine = {
    enable = true;
    efiSupport = true;
    extraEntries = ''
      /memtest86
        protocol: efi
        path: boot():///limine/efi/memtest86/memtest86.efi
    '';
    # 25.11 upgrade
    # extraConfig = ''
      # interface_help_hidden: yes
      # interface_branding:
      # term_font_scale: 2x2
    # '';
    enableEditor = true;
    additionalFiles = {
      "efi/memtest86/memtest86.efi" = "${pkgs.memtest86-efi}/BOOTX64.efi";
    };
    style = {
      interface = {
        # branding = null; # broken
        # helpHidden = true; # broken
      };
      wallpapers = [
        ./boot.jpg
      ];
    };

  };

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # (final: prev: {
        # apparmor-d = final.callPackage ./apparmor/apparmor-d_package.nix { };
      # })
    ];
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "python3.12-ecdsa-0.19.1"
        "qtwebengine-5.15.19"
      ];
    };
  };

  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
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
      channel.enable = false;

      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

  security.sudo.extraRules = [
    {
      users = [ "averdow" ];
      commands = [
        {
          # command = "${pkgs.util-linux}/bin/dmesg";
          command = "/run/current-system/sw/bin/dmesg";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.liboping}/bin/noping";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  users.users = {
    averdow = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ ];
      extraGroups = [
        "networkmanager"
        "wheel"
        "adm"
        "input"
        "audio"
        "docker"
        "dialout"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    nix-output-monitor # nom upgrades nix with prettier output
    neovim
    btop
    git
    nh # uses packages above for os builds
    liboping
    gdu
    screen
    kitty
    nix
  ];

  networking.networkmanager = {
    enable = true;
    wifi.powersave = false; # helps with barrier and mouse jumps?
  };

  time.timeZone = "America/Chicago";

  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no";
    };
  };

  environment.sessionVariables = {
    MOZ_USE_XINPUT2 = "1"; # touchscreen support for firefox
    NH_FLAKE = "/home/averdow/git/nix"; # used by nix helper
    MANPAGER = "nvim +Man!";
    NIX_SHELL_PRESERVE_PROMPT = 1;
    NIXPKGS_ALLOW_UNFREE = 1;
    EDITOR = "nvim";
    OLLAMA_API_BASE = "http://titanic-tail:11434";
    OLLAMA_HOST = "http://titanic-tail:11434";
  };

  zramSwap = {
    enable = true;
    algorithm = "lz4"; # lz4 or zstd. Currently on lz4 for higher speeds during compile
    memoryPercent = 100; # available uncompressed space, relative to RAM
  };

  # Reduce swappiness to avoid excessive swapping
  boot.kernel.sysctl = {
    "vm.swappiness" = 20; # Default 60, lower for less swapping
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
