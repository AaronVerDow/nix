{ inputs, outputs, config, pkgs, ... }:    
{
  imports =
    [
      ./hardware-configuration.nix
      ../../common/configuration.nix
    ];
  networking.hostName = "smartboard";
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;

  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "averdow";

  # bug?  https://github.com/NixOS/nixpkgs/issues/103746
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

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
        until output=$( xrandr | grep 'HDMI-. connected' | grep -o 'HDMI-.' ); do
            sleep 1
        done
        sleep 3
        xrandr --output "$output" --off
        sleep 1
        xrandr --output "$output" --auto
      '';
    };
  in ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="0b8c", ATTR{idProduct}=="00a1", ACTION=="add", RUN+="${pkgs.sudo}/bin/sudo -u averdow ${hdmiReset}/bin/hdmiReset"
  '';

  programs.fuse.userAllowOther = true;

  fileSystems."/plex/tv" = {
    device = "averdow@files.verdow.lan:tv";
    fsType = "fuse.sshfs";
    options = [
      "identityfile=/home/averdow/.ssh/id_ed25519"
      "idmap=user"
      "x-systemd.automount"
      "allow_other"
      "user"
      "uid=1000"
      "gid=100"
      "_netdev"
    ];
  };

  fileSystems."/plex/movies" = {
    device = "averdow@files.verdow.lan:movies";
    fsType = "fuse.sshfs";
    options = [
      "identityfile=/home/averdow/.ssh/id_ed25519"
      "idmap=user"
      "x-systemd.automount"
      "allow_other"
      "user"
      "uid=1000"
      "gid=100"
      "_netdev"
    ];
  };

  boot.supportedFilesystems."fuse.sshfs" = true;

  services.plex = {
    enable = true;
    openFirewall = true;
    user = "averdow";
    group = "users";
    accelerationDevices = [ "*" ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      averdow = import ./home.nix;
    };
  };
}
