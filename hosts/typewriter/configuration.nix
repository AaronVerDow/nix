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
in
{
  imports = [
    ./hardware-configuration.nix
    ../../common/configuration.nix
    ../../common/cache_client.nix
  ];

  # Small disk: collect old store paths aggressively and preemptively before
  # the disk fills during builds.
  nix.gc.options = lib.mkForce "--delete-older-than 3d";
  nix.settings = {
    min-free = 1024 * 1024 * 1024;
    max-free = 3 * 1024 * 1024 * 1024;
  };

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
