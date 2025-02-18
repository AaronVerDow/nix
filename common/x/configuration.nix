{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  programs.steam.enable = true;
  services.touchegg.enable = true;
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.cups-brother-hll2340dw ];

  services.xserver.enable = true;
  hardware.graphics.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.windowManager.awesome = {
    enable = true;
    luaModules = [ 
      pkgs.awesome-wm-widgets
    ];
  };

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

  # recommended for audio
  security.rtkit.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  hardware.keyboard.qmk.enable = true;

  services.solaar = {
    enable = true;
    package = pkgs.solaar;
    window = "hide"; # hide startup window
    batteryIcons = "regular";
    # batteryIcons = "symbolic";
    # batteryIcons = "solaar";
    extraArgs = "";
  };
}
