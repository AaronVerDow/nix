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
    ];

    systemd.services.jenkins-agent = {
      description = "Jenkins Agent";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

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
      mkdir -p "${cfg.homeDir}"
      cd "${cfg.homeDir}"
      
      # Download the agent jar
      curl -sO ${cfg.controllerUrl}/jnlpJars/agent.jar
      
      # Create the start script
      cat > "${cfg.homeDir}/start-agent.sh" << 'EOF'
      #!/bin/bash
      cd "${cfg.homeDir}"
      
      # Download latest agent jar
      curl -sO ${cfg.controllerUrl}/jnlpJars/agent.jar
      
      # Start the agent
      java -jar agent.jar \
        -jnlpUrl "${cfg.controllerUrl}/computer/${cfg.nodeName}/jenkins-agent.jnlp" \
        -secret "@${cfg.secretFile}" \
        -workDir "${cfg.homeDir}"
      EOF
      
      chmod +x "${cfg.homeDir}/start-agent.sh"
    '';
  };
}
