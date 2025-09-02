{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.jenkins-agent;
in
{
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
      description = "Name of the Jenkins node, must match name of agent in Jenkins controller.";
    };

    secretFile = mkOption {
      type = types.str;
      default = "/var/lib/jenkins-agent/.secret-file";
      description = "Path to file containing the secret token for Jenkins agent authentication.";
    };

    workingDir = mkOption {
      type = types.str;
      default = "/var/lib/jenkins-agent";
      description = "Working directory for the Jenkins agent";
    };
  };

  config = mkIf cfg.enable {
    users.users.jenkins = {
      isSystemUser = true;
      home = "${cfg.workingDir}";
      group = "jenkins";
      createHome = true;
      shell = pkgs.bash;
    };

    users.groups.jenkins = { };

    environment.systemPackages = with pkgs; [
      jdk
      curl
    ];

    systemd.services.jenkins-agent = {
      description = "Jenkins Agent";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      restartIfChanged = true;

      serviceConfig = {
        Type = "simple";
        User = "jenkins";
        WorkingDirectory = "${cfg.workingDir}";
        ExecStart = "${pkgs.bash}/bin/bash ${cfg.workingDir}/start-agent.sh";
        Environment = "PATH=$PATH:${pkgs.busybox}/bin:${pkgs.git}/bin:${pkgs.nix}/bin:${pkgs.openssh}/bin";
        Restart = "always";
        RestartSec = 10;
      };

      unitConfig = {
        StartLimitBurst = 6;
        StartLimitInterval = 120;
      };
    };

    systemd.services.jenkins-agent.preStart = ''
      set -x
      mkdir -p "${cfg.workingDir}"

      # Create the start script
      cat > "${cfg.workingDir}/start-agent.sh" << 'EOF'
      #!${pkgs.bash}/bin/bash
      set -x
      cd "${cfg.workingDir}"

      if [ ! -f "${cfg.secretFile}" ]; then
        echo "Secret file does not exist!"
        echo "Please add Jenkins secret to ${cfg.secretFile}"
        exit 1
      fi

      jar_url=${cfg.controllerUrl}/jnlpJars/agent.jar
      if ! ${pkgs.curl}/bin/curl -sO $jar_url; then
        echo "Failed to download agent.jar from $jar_url"
        echo "Please check services.jenkins-agent.controllerUrl"
        exit 1
      fi

      ${pkgs.jdk}/bin/java -jar agent.jar \
        -url "${cfg.controllerUrl}" \
        -name "${cfg.nodeName}" \
        -secret "@${cfg.secretFile}" \
        -workDir "${cfg.workingDir}"
      EOF

      chmod +x "${cfg.workingDir}/start-agent.sh"
    '';
  };
}
