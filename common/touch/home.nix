# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:

{
  imports = [
    ./dconf/onboard.nix
  ];

  home.packages = lib.mkMerge [
    (with pkgs; [

      xrotate # Custom rotation package

      onboard # On-screen keyboard
      touchegg # Touchscreen gestures

      (writeShellScriptBin "my_touchrun" ''
        # need to add this to dotfiles still
        ${pkgs.rofi}/bin/rofi -show drun -theme ~/.config/rofi/touchscreen/touch.rasi
      '')

      (writeShellScriptBin "onboard_toggle" ''
        dbus-send --type=method_call --print-reply --dest=org.onboard.Onboard /org/onboard/Onboard/Keyboard org.onboard.Onboard.Keyboard.ToggleVisible
      '')
    ])
  ];

  home.file = {
    ".config/touchegg/touchegg.conf".source = ../dotfiles/dot_config/touchegg/touchegg.conf;
    ".config/rofi/touchscreen".source = ../dotfiles/dot_config/rofi/touchscreen;
    ".local/share/onboard/layouts/full.onboard".source =
      ../dotfiles/dot_local/share/onboard/layouts/full.onboard;
    ".local/share/onboard/layouts/full.svg".source =
      ../dotfiles/dot_local/share/onboard/layouts/full.svg;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
