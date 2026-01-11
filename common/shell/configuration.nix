# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
{

  systemd.services.update-tldr = {
    description = "Update tldr database";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.tldr}/bin/tldr --update";
      User = "averdow";
    };
  };

  systemd.timers.update-tldr = {
    description = "Weekly timer for updating tldr database";
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
