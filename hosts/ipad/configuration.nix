{ inputs, outputs, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../common/configuration.nix
    ../../common/x/configuration.nix
    ../../common/cache_client.nix
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

  services.redshift.enable = true;

  services.tailscale.enable = true;

  services.kanata-config = {
    enable = true;
    internalKeyboardDeviceFilter = "AT Translated Set 2 keyboard";
  };

  virtualisation = {
    docker.enable = true;
    virtualbox = {
      host = {
        enable = true;
        enableExtensionPack = true;
      };
    };
  };

  # Add user to vboxusers group for VirtualBox access
  users.users.averdow.extraGroups = [ "vboxusers" ];

  # Enable Vagrant
  environment.systemPackages = with pkgs; [
    vagrant
  ];

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = { averdow = import ./home.nix; };
  };
}
