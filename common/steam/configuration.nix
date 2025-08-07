{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  # Jovian NixOS configuration for Steam Deck-like experience
  jovian = {
    steam = {
      enable = true;
      autoStart = false;
      desktopSession = "awesome";
    };
  };

  # Additional Steam-related configurations
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Gaming optimizations
  programs.gamemode.enable = true;
}
