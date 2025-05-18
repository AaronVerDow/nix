# Kanata keyboard configuration module
{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.kanata-config;
in {
  options.services.kanata-config = {
    enable = mkEnableOption "kanata keyboard configuration";

    internalKeyboardConfig = mkOption {
      type = types.str;
      default = builtins.readFile ./internal_alias.kbd;
      description = "Configuration for internal keyboard";
    };

    externalKeyboardConfig = mkOption {
      type = types.str;
      default = builtins.readFile ./external_alias.kbd;
      description = "Configuration for external keyboard";
    };

    baseConfig = mkOption {
      type = types.str;
      default = builtins.readFile ./kanata.kbd;
      description = "Base configuration shared between keyboards";
    };

    internalKeyboardDeviceFilter = mkOption {
      type = types.nullOr types.str;
      default = null;
      description =
        "Device name filter for internal keyboard. If null, only external keyboard config will be used.";
    };
  };

  config = mkIf cfg.enable {
    services.kanata = {
      enable = true;
      keyboards = mkMerge [
        # Always include external keyboard configuration
        {
          externalKeyboard = {
            extraDefCfg = ''
              log-layer-changes no
              process-unmapped-keys yes
              ${optionalString (cfg.internalKeyboardDeviceFilter != null) ''
                linux-dev-names-exclude (
                  "${cfg.internalKeyboardDeviceFilter}"
                )
              ''}
            '';
            config = cfg.baseConfig + cfg.externalKeyboardConfig;
          };
        }
        # Only include internal keyboard configuration if a device filter is specified
        (mkIf (cfg.internalKeyboardDeviceFilter != null) {
          internalKeyboard = {
            extraDefCfg = ''
              log-layer-changes no
              process-unmapped-keys yes
              linux-dev-names-include (
                "${cfg.internalKeyboardDeviceFilter}"
              )
            '';
            config = cfg.baseConfig + cfg.internalKeyboardConfig;
          };
        })
      ];
    };
  };
}
