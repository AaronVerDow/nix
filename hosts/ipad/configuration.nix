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
    ];
  networking.hostName = "ipad";
  services.xserver.videoDrivers = ["amdgpu"];

  # Primary desk flag
  # 2109:2813

  # Secondary flag
  # 291a:a392

  services.kanata = {
    enable = true;
    keyboards = {
      internalKeyboard = {
        devices = [
          "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
          "/dev/input/by-id/usb-Logitech_USB_Receiver-if02-event-mouse"
        ];
        extraDefCfg = "process-unmapped-keys yes";
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
