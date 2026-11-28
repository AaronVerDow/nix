{
  inputs,
  outputs,
  lib,
  pkgs,
  ...
}:
let
  user = "averdow";
  repo = "/home/${user}/git/typewriter-predictive-margins";
  typewriterSession = pkgs.writeShellScript "typewriter-session" ''
    set -eu

    export PATH=${
      lib.makeBinPath [
        pkgs.coreutils
        pkgs.git
        pkgs.nix
      ]
    }:$PATH

    # Serve the curses display mirror on the LAN.
    export TYPEWRITER_WEB_HOST=0.0.0.0
    export TYPEWRITER_WEB_PORT=8080

    if [ -d "${repo}/.git" ]; then
      ${pkgs.git}/bin/git -C "${repo}" pull --ff-only || true
    else
      mkdir -p "$(dirname "${repo}")"
      ${pkgs.git}/bin/git clone git@github.com:AaronVerDow/typewriter-predictive-margins.git "${repo}"
    fi

    cd "${repo}"
    exec ${pkgs.nix}/bin/nix develop --command typewriter
  '';
  typingActivity = pkgs.python3.withPackages (ps: [ ps.evdev ]);
in
{
  imports = [
    ./hardware-configuration.nix
    ../../common/configuration.nix
    ../../common/cache_client.nix
  ];

  # The Nix store lives on the dedicated USB drive, so keep collecting old
  # store paths aggressively rather than letting it fill up during builds.
  nix.gc.options = lib.mkForce "--delete-older-than 3d";
  nix.settings = {
    min-free = 1024 * 1024 * 1024;
    max-free = 3 * 1024 * 1024 * 1024;
  };

  # Nix store on the USB drive. It must be mounted in stage 1 before the
  # activation script and nix-daemon need it.
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/e60c7697-e1cf-4361-8567-1753ce056317";
    fsType = "ext4";
    options = [ "noatime" ];
    neededForBoot = true;
  };

  # The store disk is a UAS device; without uas in the initrd, stage 1 cannot
  # see /dev/sda and boot fails before /nix can be mounted.
  boot.initrd.kernelModules = [
    "uas"
    "usb_storage"
    "sd_mod"
    "xhci_pci"
  ];

  # VIA keyboard tooling is useless on this headless appliance and costs ~1.6 GiB.
  my.udev.via.enable = false;

  # Bound kernel/initrd generations and log usage on the small volume.
  boot.loader.systemd-boot.configurationLimit = 3;
  services.journald.extraConfig = "SystemMaxUse=200M";
  documentation.nixos.enable = false;

  networking.hostName = "typewriter";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Keep systemd-boot on this appliance instead of the common limine setup.
  boot.loader.limine.enable = lib.mkForce false;

  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 8080 ];

  # The typewriter app runs on the console, where terminal input cannot report
  # Super-key combinations. Remap its Super shortcuts to the equivalent
  # function keys so they work with any attached keyboard.
  services.kanata-config = {
    enable = true;
    baseConfig = builtins.readFile ./kanata.kbd;
    externalKeyboardConfig = "";
  };

  # Let Home Assistant keep the library lights on while the typewriter is in use.
  systemd.services.typing-activity = {
    description = "Report typewriter keyboard activity to Home Assistant";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${typingActivity}/bin/python ${./typing-activity.py}";
      User = user;
      SupplementaryGroups = [ "input" ];
      Environment = [
        "TYPING_WEBHOOK_URL=http://homeassistant.verdow.lan:8123/api/webhook/typing_activity"
      ];
      Restart = "always";
      RestartSec = 5;
    };
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
  };

  time.timeZone = "America/Chicago";

  users.users.${user} = {
    isNormalUser = true;
    initialPassword = "correcthorsebatterystaple";
    extraGroups = [
      "wheel"
      "dialout"
      "input"
      "video"
    ];
  };

  # Headless console appliance: boot straight into the typewriter interface.
  services.getty.autologinUser = user;

  environment.loginShellInit = ''
    if [ "$(${pkgs.coreutils}/bin/tty)" = "/dev/tty1" ]; then
      exec ${typewriterSession}
    fi
  '';

  environment.systemPackages = with pkgs; [
    git
    neovim
    nh
    nix
  ];

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      ${user} = import ./home.nix;
    };
  };

  system.stateVersion = "23.05";
}
