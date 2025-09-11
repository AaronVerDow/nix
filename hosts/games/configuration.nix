{ inputs, outputs, pkgs, lib, ... }: {
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

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.limine = {
    enable = true;
    efiSupport = true;
    extraConfig = ''
      timeout: no
    '';
    extraEntries = ''
      /Windows
        protocol: bios
        partition: uuid(FA220C37220BF801)
      /memtest86
        protocol: efi
        path: boot():///limine/efi/memtest86/memtest86.efi
    '';
    enableEditor = true;
    additionalFiles = { "efi/memtest86/memtest86.efi" = "${pkgs.memtest86-efi}/BOOTX64.efi"; };
    style = {
      interface = {
        branding = null;
        helpHidden = true;
      };
      wallpapers = [ 
        ./boot.jpg
      ];
    };

  };



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
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  # virtualisation.virtualbox.host.enableKvm = true;
  virtualisation.virtualbox.host.addNetworkInterface = false;

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
