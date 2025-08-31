{ inputs, outputs, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../common/configuration.nix
    ../../common/x/configuration.nix
    ../../common/cache_client.nix
  ];
  networking.hostName = "games";

  powerManagement.enable = true;

  services.tailscale.enable = true;

  hardware.nvidia-container-toolkit.enable = true;
  hardware.graphics.enable32Bit = true;
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia.open = true; # required for RTX?
  hardware.graphics.enable = true;
  nixpkgs.config.cudaSupport = true;

  programs = {
    gamescope = {
      enable = true;
      capSysNice = true;
    };
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
  };
  hardware.xone.enable = true;

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
