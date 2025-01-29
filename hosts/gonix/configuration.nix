{ inputs, outputs, ... }:
let
  internalAlias = builtins.readFile ../../common/kanata/internal_alias.kbd;
  externalAlias = builtins.readFile ../../common/kanata/external_alias.kbd;
  kanataConfig = builtins.readFile ../../common/kanata/monolith.kbd;
in
{
  imports =
    [
      ./hardware-configuration.nix
      ../../common/configuration.nix
      ../../common/x/configuration.nix
    ];
  networking.hostName = "gonix";

  services.kanata = {
    enable = true;
    keyboards = {
/*
      external = {
        devices = [
          "/dev/input/by-id/usb-Keychron_Keychron_K9_Pro-event-kbd"
          "/dev/input/by-id/usb-Keychron_Keychron_K9_Pro-if02-event-kbd"
        ];
        extraDefCfg = ''
          process-unmapped-keys yes
          log-layer-changes no
        '';
        config = kanataConfig + externalAlias;
      };
*/
      internal = {
        devices = [
          "/dev/input/by-path/pci-0000:00:14.0-usb-0:3:1.0-event-kbd"
          "/dev/input/by-path/pci-0000:00:14.0-usbv2-0:3:1.0-event-kbd"
        ];
        extraDefCfg = ''
          process-unmapped-keys yes
          log-layer-changes no
        '';
        config = kanataConfig + internalAlias;
      };
    };
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      averdow = import ./home.nix;
    };
  };
}
