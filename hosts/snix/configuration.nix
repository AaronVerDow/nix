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
