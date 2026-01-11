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
    ./thumbnailers.nix
  ];

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  services.touchegg.enable = true;
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.cups-brother-hll2340dw ];

  services.xserver.enable = true;
  hardware.graphics.enable = true;

  # doesn't work 
  services.xserver.inputClassSections = [ ''
      Identifier "Overwatch Fix"
      MatchProduct  "Logitech MX Master"
      Option          "Emulate3Buttons"       "false"
    ''
  ];

  services.xserver.displayManager.lightdm = {
    enable = true;
    greeters.gtk = {
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };
      iconTheme = {
        name = "candy-icons";
        package = pkgs.candy-icons;
      };
      cursorTheme = {
        name = "volantes_cursors";
        package = pkgs.volantes-cursors;
      };
    };
    background = "${../boot.jpg}";
  };

  services.xserver.windowManager.awesome = {
    enable = true;
    luaModules = with pkgs.luaPackages; [
      awesome-wm-widgets
    ];
  };

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

  services.dbus.enable = true;
  programs.thunar.enable = true;
  programs.xfconf.enable = true;
  programs.dconf.enable = true;
  services.tumbler.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  services.gvfs.enable = true;

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
