{
  inputs,
  outputs,
  pkgs,
  app,
  ...
}:

let
  user = "averdow";
  autostart = ''
    #!${pkgs.bash}/bin/bash
    # End all lines with '&' to not halt startup script execution

    # firefox --kiosk https://stigok.com/ &
    ${pkgs.plex-htpc}/bin/plex-htpc &
  '';

  inherit (pkgs) writeScript;
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./minimal.nix
  ];

  networking.hostName = "bedhtpc";

  # home-manager = {
    # extraSpecialArgs = { inherit inputs outputs; };
    # users = {
      # averdow = import ./home.nix;
    # };
  # };

  # services.xserver.enable = true;
  # services.greetd.enable = true;
  # services.xserver.displayManager.autoLogin.enable = true;
  # services.xserver.displayManager.autoLogin.user = "averdow";

  # services.cage = {
    # enable = true;
    # program = "${pkgs.plex-htpc}/bin/plex-htpc";
    # user = "averdow";
  # };

  services.xserver = {
    enable = true;
    layout = "us"; # keyboard layout
    libinput.enable = true;

    # Let lightdm handle autologin
    displayManager.lightdm = {
      enable = true;
      # autoLogin = {
      #   timeout = 0;
      # };
    };

    # Start openbox after autologin
    windowManager.openbox.enable = true;
    displayManager = {
      defaultSession = "none+openbox";
      autoLogin = {
        inherit user;
        enable = true;
      };
    };
  };

  systemd.services."display-manager".after = [
    "network-online.target"
    "systemd-resolved.service"
  ];

  # Overlay to set custom autostart script for openbox
  nixpkgs.overlays = with pkgs; [
    (_self: super: {
      openbox = super.openbox.overrideAttrs (_oldAttrs: rec {
        postFixup = ''
          ln -sf /etc/openbox/autostart $out/etc/xdg/openbox/autostart
        '';
      });
    })
  ];

  # By defining the script source outside of the overlay, we don't have to
  # rebuild the package every time we change the startup script.
  environment.etc."openbox/autostart".source = writeScript "autostart" autostart;

  system.stateVersion = "23.05"; # Did you read the comment?
}
