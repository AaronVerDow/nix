{ inputs, outputs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../common/configuration.nix
    ../../common/x/configuration.nix
  ];
  networking.hostName = "ipad";
  services.xserver.videoDrivers = [ "amdgpu" ];

  boot.kernelParams = [ "amd_pstate=guided" ];
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "schedutil";

  # Primary desk flag
  # 2109:2813

  # Secondary flag
  # 291a:a392

  services.kanata-config = {
    enable = true;
    internalKeyboardDeviceFilter = "AT Translated Set 2 keyboard";
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = { averdow = import ./home.nix; };
  };
}
