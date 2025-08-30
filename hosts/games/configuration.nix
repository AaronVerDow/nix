{ inputs, outputs, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../common/configuration.nix
    ../../common/x/configuration.nix
    ../../common/cache_client.nix
  ];
  networking.hostName = "games";
  services.xserver.videoDrivers = [ "amdgpu" ];

  boot.kernelParams = [ "amd_pstate=guided" ];
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "schedutil";

  services.tailscale.enable = true;

  services.kanata-config = {
    enable = true;
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
