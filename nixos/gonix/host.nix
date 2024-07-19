{ config, pkgs, ... }:    
{
  imports =
    [
      ./hardware-configuration.nix
      ../configuration.nix
    ];
  networking.hostName = "gonix";
}
