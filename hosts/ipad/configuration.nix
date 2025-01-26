{ inputs, outputs, ... }:
let
  kanataConfig = builtins.readFile ../../common/kanata/fake_vim;
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
        ];
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
