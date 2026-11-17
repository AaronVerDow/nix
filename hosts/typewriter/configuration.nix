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
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "typewriter";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      user
    ];
  };

  networking.networkmanager.enable = true;

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

  system.stateVersion = "23.05";
}
