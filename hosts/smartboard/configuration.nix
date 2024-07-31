{ inputs, outputs, config, pkgs, ... }:    
{
  imports =
    [
      ./hardware-configuration.nix
      ../../common/configuration.nix
      inputs.home-manager.nixosModules.home-manager
    ];
  networking.hostName = "smartboard";
  services.xserver.videoDrivers = ["nvidia"];

  services.udev.packages = with pkgs; [
    sudo
  ];
  services.udev.extraRules = let
    hdmiReset = pkgs.writeShellApplication {
      name = "hdmiReset";
      runtimeInputs = with pkgs; [
        xorg.xrandr
      ];
      text = ''
        export DISPLAY=:0
        until xrandr | grep "HDMI-1 connected"; do
            sleep 1
        done
        sleep 3
        xrandr --output HDMI-1 --off
        sleep 1
        xrandr --output HDMI-1 --auto
      '';
    };
  in ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="0b8c", ATTR{idProduct}=="00a1", ACTION=="add", RUN+="${pkgs.sudo}/bin/sudo -u averdow ${hdmiReset}/bin/hdmiReset"
  '';

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      averdow = import ./home.nix;
    };
  };
}
