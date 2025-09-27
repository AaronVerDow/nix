{
  inputs,
  outputs,
  pkgs,
  ...
}:
let
  thermaldConfig = pkgs.copyPathToStore ./thermal-conf.xml;
in
{
  imports = [
    ./hardware-configuration.nix
    ../../common/configuration.nix
    ../../common/cache_client.nix
    ../../common/x/configuration.nix
  ];
  networking.hostName = "gonix";

  # cache kernel compiles
  programs.ccache = {
    enable = true;
    packageNames = [ "linux" ];
  };

  services.tailscale.enable = true;
  
  services.xserver.desktopManager.cinnamon.enable = true;

  # https://github.com/linux-surface/linux-surface/wiki/Surface-Laptop-Go-2
  services.thermald = {
    enable = true;
    # https://github.com/linux-surface/linux-surface/tree/master/contrib/thermald
    configFile = thermaldConfig;
  };

  services.kanata-config = {
    enable = true;
    internalKeyboardDeviceFilter = "ELAN Touchpad and Keyboard";
  };

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "titanic";
        system = "x86_64-linux";
        sshUser = "averdow";
        # sshKey = "/home/averdow/.ssh/id_rsa";
        protocol = "ssh-ng";
        supportedFeatures = [
          "benchmark"
          "big-parallel"
          "kvm"
          "nixos-test"
        ];
      }
    ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      averdow = import ./home.nix;
    };
  };
}
