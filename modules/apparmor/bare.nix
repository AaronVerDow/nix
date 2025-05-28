{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (config.grimmShared) enable tooling;
  inherit (lib) mkIf;
in
{
  config = mkIf (enable && tooling.enable && config.security.apparmor.enable) {
    services.dbus.apparmor = "enabled";
    security.auditd.enable = true;

    security.apparmor.enableCache = true;

    environment.systemPackages = with pkgs; [ apparmor-parser ];

    #    security.apparmor.aa-alias-manager.enable = false;

    security.audit.backlogLimit = 512;

  };
}
