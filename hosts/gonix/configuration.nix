{ inputs, outputs, pkgs, ... }:
let thermaldConfig = pkgs.copyPathToStore ./thermal-conf.xml;
in {
  imports = [
    ./hardware-configuration.nix
    ../../common/configuration.nix
    ../../common/x/configuration.nix
  ];
  networking.hostName = "gonix";

  # cache kernel compiles
  programs.ccache = {
    enable = true;
    packageNames = [ "linux" ];
  };

  # https://github.com/linux-surface/linux-surface/wiki/Surface-Laptop-Go-2
  services.thermald = {
    enable = true;
    # https://github.com/linux-surface/linux-surface/tree/master/contrib/thermald
    configFile = thermaldConfig;
  };

  services.kanata-config = {
    enable = true;
    internalKeyboardDeviceFilter = "ELAN Touchpad and Keyboard";
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = { averdow = import ./home.nix; };
  };
}
