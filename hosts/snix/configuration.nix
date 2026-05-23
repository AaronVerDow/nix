{
  inputs,
  outputs,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../common/configuration.nix
    ../../common/cache_client.nix
    ../../common/x/configuration.nix
  ];

  networking.hostName = "snix";

  services.tailscale.enable = true;

  services.kanata-config = {
    enable = true;
  };

  jovian.devices.steamdeck.enable = false;
  jovian.devices.steamdeck.enableControllerUdevRules = true;
  jovian.devices.steamdeck.enableDefaultStage1Modules = true;
  jovian.devices.steamdeck.enableKernelPatches = true;
  jovian.devices.steamdeck.enableOsFanControl = true;
  jovian.devices.steamdeck.enablePerfControlUdevRules = true;
  jovian.devices.steamdeck.enableXorgRotation = true;
  jovian.steamos.enableBluetoothConfig = true;
  jovian.steamos.enableZram = true;
  jovian.hardware.has.amd.gpu = true;

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
