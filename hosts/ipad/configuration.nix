{ inputs, outputs, ... }:
let
  internalAlias = builtins.readFile ../../common/kanata/internal_alias.kbd;
  externalAlias = builtins.readFile ../../common/kanata/external_alias.kbd;
  kanataConfig = builtins.readFile ../../common/kanata/kanata.kbd;
in
{
  imports =
    [
      ./hardware-configuration.nix
      ../../common/configuration.nix
      ../../common/x/configuration.nix
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
        extraDefCfg = ''
          log-layer-changes no
          process-unmapped-keys yes
          linux-dev-names-include (
            "AT Translated Set 2 keyboard"
          )
        '';
        config = kanataConfig + internalAlias;
      };
      externalKeyboard = {
        extraDefCfg = ''
          log-layer-changes no
          process-unmapped-keys yes
          linux-dev-names-exclude (
            "AT Translated Set 2 keyboard"
          )
        '';
        config = kanataConfig + externalAlias;
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
