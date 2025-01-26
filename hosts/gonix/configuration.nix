{ inputs, outputs, ... }:
let
  disableKeyboard = builtins.readFile ../../common/kanata/disable_keyboard.kbd;
  kanataConfig = builtins.readFile ../../common/kanata/fake_vim;
in
{
  imports =
    [
      ./hardware-configuration.nix
      ../../common/configuration.nix
    ];
  networking.hostName = "gonix";

  services.kanata = {
    enable = true;
    keyboards = {
      disable_keyboard = {
        devices = [
          # Replace the paths below with the appropriate device paths for your setup.
          # Use `ls /dev/input/by-path/` to find your keyboard devices.
          "/dev/input/by-path/pci-0000:00:14.0-usb-0:3:1.0-event-kbd"
          "/dev/input/by-path/pci-0000:00:14.0-usbv2-0:3:1.0-event-kbd"
        ];
        extraDefCfg = "process-unmapped-keys yes";
        config = disableKeyboard;
      };
      internalKeyboard = {
        extraDefCfg = "process-unmapped-keys yes";
        config = kanataConfig;
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
