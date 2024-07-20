{ config, pkgs, ... }:    
{
  imports =
    [
      ./hardware-configuration.nix
      ../configuration.nix
    ];
  networking.hostName = "ipad";
  services.xserver.videoDrivers = ["amdgpu"];
}
