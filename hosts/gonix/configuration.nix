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
  networking.hostName = "gonix";

  services.kanata = {
    enable = true;
    keyboards = {
      internalKeyboard = {
        extraDefCfg = ''
          log-layer-changes no
          process-unmapped-keys yes
          linux-dev-names-include (
            "ELAN Touchpad and Keyboard"
          )
        '';
        config = kanataConfig + internalAlias;
      };
      externalKeyboard = {
        extraDefCfg = ''
          process-unmapped-keys yes
          linux-dev-names-exclude (
            "ELAN Touchpad and Keyboard"
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
