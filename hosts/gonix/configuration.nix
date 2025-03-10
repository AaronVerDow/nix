{ inputs, outputs, pkgs, ... }:
let
  internalAlias = builtins.readFile ../../common/kanata/internal_alias.kbd;
  externalAlias = builtins.readFile ../../common/kanata/external_alias.kbd;
  kanataConfig = builtins.readFile ../../common/kanata/kanata.kbd;
  thermaldConfig = pkgs.copyPathToStore ./thermal-conf.xml;
in
{
  imports =
    [
      ./hardware-configuration.nix
      ../../common/configuration.nix
      ../../common/x/configuration.nix
    ];
  networking.hostName = "gonix";

  # cache kernel compiles
  programs.ccache = {
    enable = true;
    packageNames = [
      "linux"
    ];
  };

  # https://github.com/linux-surface/linux-surface/wiki/Surface-Laptop-Go-2
  services.thermald = {
    enable = true;
    # https://github.com/linux-surface/linux-surface/tree/master/contrib/thermald
    configFile = thermaldConfig;
  };

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
