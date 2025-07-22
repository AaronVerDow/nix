{ inputs, outputs, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../common/configuration.nix
    ];

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "9cd45734";
  services.zfs.autoScrub.enable = true;
  boot.zfs.extraPools = [ "array" ];

  networking.hostName = "titanic"; # Define your hostname.

  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  virtualisation.docker.enable = true;

  # Required to serve as a remote nix builder
  services.openssh.settings.PermitRootLogin = lib.mkForce "prohibit-password";

  services.xserver.videoDrivers = ["nvidia"];
  # services.xserver.enable = false;
  hardware.nvidia.open = true; # required for RTX?
  hardware.graphics.enable = true;
  nixpkgs.config.cudaSupport = true;
  services.ollama = {
    enable = true;
    host = "127.0.0.1";
    port = 11434;
    acceleration = "cuda";
    environmentVariables = {
      # Recommended for aider
      OLLAMA_CONTEXT_LENGTH=8192;
    };
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "titanic";
        "netbios name" = "titanic";
        security = "user";
        #use sendfile = yes;
        #max protocol = smb2;
        # note: localhost is the ipv6 localhost ::1
        "hosts allow" = "10.44.12. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      consume = {
        path = "/home/averdow/containers/paperless/consume";
        browseable = "no";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8080 443 135 32400 9080 80 5000 ];

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      averdow = import ./home.nix;
    };
  };
  
  system.stateVersion = "23.05"; # Did you read the comment?
}
