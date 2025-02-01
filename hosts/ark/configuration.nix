{ inputs, outputs, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../common/configuration.nix
    ];

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "8b750a1e";
  services.zfs.autoScrub.enable = true;
  boot.zfs.extraPools = [ "array" ];

  networking.hostName = "ark"; # Define your hostname.

  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  virtualisation.docker.enable = true;

  services.samba = {
    enable = true;
    securityType = "user";
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "ark";
        "netbios name" = "ark";
        security = "user";
        #use sendfile = yes;
        #max protocol = smb2;
        # note: localhost is the ipv6 localhost ::1
        "hosts allow" = "10.44.12. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
    };
    shares = {
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


  networking.firewall.allowedTCPPorts = [ 8080 443 135 32400 9080 80 ];

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      averdow = import ./home.nix;
    };
  };
  
  system.stateVersion = "23.05"; # Did you read the comment?
}
