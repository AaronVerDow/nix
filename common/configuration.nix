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
  # You can import other NixOS modules here
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./apparmor/apparmor_d_module.nix
  ];

  i18n.defaultLocale = "en_US.UTF-8";

  # used by redshift
  location = {
    # provider = "geoclue2";
    provider = "manual";
    latitude = 41.8832;
    longitude = -87.6324;
  };

  boot.loader.limine = {
    enable = true;
    efiSupport = true;
    extraEntries = ''
      /memtest86
        protocol: efi
        path: boot():///limine/efi/memtest86/memtest86.efi
    '';
    extraConfig = ''
      interface_help_hidden: yes
      interface_branding:
      term_font_scale: 2x2
    '';
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

  # required for apropos and qman, but makes builds longer
  # documentation.man.generateCaches = true;

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      (final: prev: {
        apparmor-d = final.callPackage ./apparmor/apparmor-d_package.nix { };
      })
    ];
    config = {
      allowUnfree = true;
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
      initialPassword = "correcthorsebatterystaple";
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
      packages = with pkgs; [
        neofetch
        neovim
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
        which
        jq
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    nix-output-monitor # nom upgrades nix with prettier output
    nvd # diff derevations
    nh # uses packages above for os builds
    liboping
    gdu
    restic
    screen
    kitty
    apparmor-parser

    # jenkins temp fix
    git
    nix
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
      X11Forwarding = true;
      PermitRootLogin = "no";
    };
  };

  services.logind.extraConfig = ''
    # don't shutdown when power button is short-pressed
    HandlePowerKey="ignore";
  '';

  environment.sessionVariables = {
    MOZ_USE_XINPUT2 = "1"; # touchscreen support for firefox
    NH_FLAKE = "/home/averdow/git/nix"; # used by nix helper
    MANPAGER = "nvim +Man!";
  };

  services.udev.packages = with pkgs; [ unstable.via ];
  # Keychron isn't currenlty included by via
  services.udev.extraRules = ''
    # K9 Pro
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0290", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    # K7 Pro
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0270", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    # Kanata
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
  '';

  systemd.services.update-tldr = {
    description = "Update tldr database";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.tldr}/bin/tldr --update";
      User = "averdow";
    };
  };

  systemd.timers.update-tldr = {
    description = "Weekly timer for updating tldr database";
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
  };

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

  zramSwap = {
    enable = true;
    algorithm = "lz4"; # lz4 or zstd. Currently on lz4 for higher speeds during compile
    memoryPercent = 100; # available uncompressed space, relative to RAM
  };

  # Reduce swappiness to avoid excessive swapping
  boot.kernel.sysctl = {
    "vm.swappiness" = 20; # Default 60, lower for less swapping
  };

  # this will trigger additional configuration in ./apparmor.nix
  security.apparmor.enable = false;

  # add a boot entry with apparmor enabled
  specialisation = {
    with-apparmor = {
      configuration = {
        security.apparmor.enable = lib.mkForce true;
      };
    };
  };

  services.dbus.apparmor = "enabled";
  security.auditd.enable = true;

  # security.apparmor.enable = lib.mkDefault true;
  security.apparmor.enableCache = true;
  security.apparmor.killUnconfinedConfinables = false;

  security.audit.backlogLimit = 8192;

  security.apparmor_d = {
    enable = true;
    profiles = {
      discord = "enforce";
      # can't download files in enforce mode
      "firefox.apparmor.d" = "complain";
      ollama = "enforce";
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
