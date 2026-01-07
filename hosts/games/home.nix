{ pkgs, ... }:

{
  imports = [
    ../../common/home.nix
    ../../common/x/home.nix
  ];

  home.packages = with pkgs; [
    unstable.r2modman
    protonup-qt
    # huestacean
    (writeShellScriptBin "undock" ''
      xrandr --output DP-1 --off
      wallpaper_set
    '')
    (writeShellScriptBin "dual" ''
      xrandr --output DP-1 --auto --pos 760x1440
      wallpaper_set
    '')
  ];
  
  programs.lutris = {
    enable = true;
    winePackages = [
      pkgs.wine
    ];
  };

  xdg.desktopEntries = {
    dual = {
      name = "Dual Screen";
      exec = "dual";
      icon = "video-display";
      type = "Application";
    };
  };

  xdg.desktopEntries = {
    undock = {
      name = "Undock";
      exec = "undock";
      icon = "video-display";
      type = "Application";
    };
  };
}
