{ lib, pkgs, config, ... }:
{
  options.my.udev.via.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Install the VIA keyboard configuration tool and udev rules.";
  };

  config = lib.mkIf config.my.udev.via.enable {
    services.udev.packages = [ pkgs.unstable.via ];
  };
}
