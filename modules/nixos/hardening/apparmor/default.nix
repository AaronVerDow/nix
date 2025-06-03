{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkIf
    getExe'
    getExe
    optional
    ;
in
{
  imports = [ ./apparmor-d-module.nix ];

  config = mkIf config.security.apparmor.enable {
    services.dbus.apparmor = "enabled";
    security.auditd.enable = true;

    security.apparmor.enableCache = true;
    security.apparmor.killUnconfinedConfinables = false;

    environment.systemPackages = with pkgs; [ apparmor-parser ];

    security.audit.backlogLimit = 8192;

    security.apparmor_d = {
      enable = true;
      profiles = {
        discord = "enforce";
      };
    };

    security.apparmor.includes = {
      "abstractions/base" = ''
        /nix/store/*/bin/** mr,
        /nix/store/*/lib/** mr,
        /nix/store/** r,
      '';
    };
  };
}
