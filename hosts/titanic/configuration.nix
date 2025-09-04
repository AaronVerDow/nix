{ inputs, outputs, pkgs, lib, ... }:

{
  disabledModules = [ "services/networking/x2goserver.nix" ];
  imports = [ 
    ./hardware-configuration.nix
    ../../common/configuration.nix
    ../../common/x/configuration.nix
    ./selfhosted/selfhosted.nix
    ./x2goserver.nix
  ];

  services.xserver.displayManager.gdm.autoSuspend = false;

  services.redshift.enable = lib.mkForce false;
  services.tailscale.enable = true;

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "9cd45734";
  services.zfs.autoScrub.enable = true;
  boot.zfs.extraPools = [ "array" ];

  networking.hostName = "titanic"; # Define your hostname.

  # sudo iptables -t nat -A POSTROUTING -o enp9s0 -j MASQUERADE # temporary fix
  # Install Instance Identity plugin
  # Add agent with matching name

  services.jenkins-agent = {
    enable = true;
    controllerUrl = "http://127.0.0.1:8088";
  };

  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  # not working with plex
  hardware.nvidia-container-toolkit.enable = true;
  hardware.graphics.enable32Bit = true;
  virtualisation.docker = {
    enable = true;
    # enableNvidia = true;
  };

  services.x2goserver = {
    enable = true;
    # build is currently broken in stable
    package = pkgs.unstable.x2goserver;
  };

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "${pkgs.awesomeWithWidgets}/bin/awesome";
  services.xrdp.openFirewall = true;

  services.nix-serve = {
    enable = true;
    secretKeyFile = "/var/cache-priv-key.pem";
  };

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  # Required to serve as a remote nix builder
  services.openssh.settings.PermitRootLogin = lib.mkForce "prohibit-password";

  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia.open = true; # required for RTX?
  hardware.graphics.enable = true;
  nixpkgs.config.cudaSupport = true;
  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    port = 11434;
    acceleration = "cuda";
    environmentVariables = {
      # Recommended for aider
      "OLLAMA_CONTEXT_LENGTH" = "8192";
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

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  networking.networkmanager.unmanaged = [ "interface-name:ve-*" ];
  networking.firewall.allowedTCPPorts = [ 8080 443 135 32400 9080 80 5000 8088 50000 ];
  containers.jenkins = {
    config = { pkgs, ... }: {
      services.jenkins = {
        enable = true;
        port = 8088;
        extraJavaOptions = [
          "-Djenkins.model.Jenkins.slaveAgentPort=50000"  # For JNLP agents
          "-Dorg.jenkinsci.plugins.durabletask.BourneShellScript.LAUNCH_DIAGNOSTICS=true"
        ];
      };
      networking.firewall.allowedTCPPorts = [ 8088 50000 ];
    };
    autoStart = true;
    restartIfChanged = true;
    privateNetwork = false;
    bindMounts = {
      # "/nix" = { hostPath = "/nix"; };
      "/var/lib/jenkins" = { hostPath = "/home/averdow/services/jenkins"; isReadOnly = false; }; 
    };
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      averdow = import ./home.nix;
    };
  };
  
  system.stateVersion = "23.05"; # Did you read the comment?
}
