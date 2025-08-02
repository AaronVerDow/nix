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
  };

  config = mkIf cfg.enable {
  };
}
