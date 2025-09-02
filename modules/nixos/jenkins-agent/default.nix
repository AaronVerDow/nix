{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.jenkins-agent;
in {
  options.services.jenkins-agent = {
    enable = mkEnableOption "Jenkins Agent";

    controllerUrl = mkOption {
      type = types.str;
      default = "http://127.0.0.1:8080";
      description = "URL for Jenkins Controller";
    };

    nodeName = mkOption {
      type = types.str;
      default = "nixos-agent";
      description = "Name of the Jenkins node";
    };

    secretFile = mkOption {
      type = types.str;
      default = "/home/jenkins/.secret";
      description = "Path to file containing the secret token for Jenkins agent authentication";
    };

    homeDir = mkOption {
      type = types.str;
      default = "/home/jenkins";
      description = "Working directory for the Jenkins agent";
    };
  };

  config = mkIf cfg.enable {
    users.users.jenkins = {
      isSystemUser = true;
      home = "${cfg.homeDir}";
      group = "jenkins";
      createHome = true;
      shell = pkgs.bash;
    };

    users.groups.jenkins = {};

    environment.systemPackages = with pkgs; [
      jdk
      curl
      # not sure if these are needed
      git
      nix
      openssh
    ];

    systemd.services.jenkins-agent = {
      description = "Jenkins Agent";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      reloadIfChanged = true;

      serviceConfig = {
        Type = "simple";
        User = "jenkins";
        WorkingDirectory = "${cfg.homeDir}";
        ExecStart = "${pkgs.bash}/bin/bash ${cfg.homeDir}/start-agent.sh";
        Restart = "always";
        RestartSec = 10;
      };
    };

    # Create the startup script
    systemd.services.jenkins-agent.preStart = ''
      set -x
      mkdir -p "${cfg.homeDir}"
      cd "${cfg.homeDir}"
      
      # Download the agent jar
      ${pkgs.curl}/bin/curl -sO ${cfg.controllerUrl}/jnlpJars/agent.jar
      
      # Create the start script
      cat > "${cfg.homeDir}/start-agent.sh" << 'EOF'
      #!${pkgs.bash}/bin/bash
      set -x
      export PATH="$PATH:${pkgs.git}/bin:${pkgs.nix}/bin:${pkgs.openssh}/bin"
      cd "${cfg.homeDir}"

      # Download latest agent jar
      ${pkgs.curl}/bin/curl -sO ${cfg.controllerUrl}/jnlpJars/agent.jar
      
      # Start the agent
      ${pkgs.jdk}/bin/java -jar agent.jar \
        -url "${cfg.controllerUrl}" \
        -name "${cfg.nodeName}" \
        -secret "@${cfg.secretFile}" \
        -workDir "${cfg.homeDir}"
      EOF
      
      chmod +x "${cfg.homeDir}/start-agent.sh"
    '';
  };
}
