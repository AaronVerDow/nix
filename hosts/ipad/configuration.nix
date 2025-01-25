{ inputs, outputs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ../../common/configuration.nix
    ];
  networking.hostName = "ipad";
  services.xserver.videoDrivers = ["amdgpu"];

  # Primary desk flag
  # 2109:2813

  # Secondary flag
  # 291a:a392

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      averdow = import ./home.nix;
    };
  };
}
