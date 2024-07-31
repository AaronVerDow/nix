# My NixOS Flake & Dotfiles
* AwesomeWM
* Dark mode
* Touchscreen support
  * Gestures
  * Titlebars on floating windows
  * Onscreen keyboard

# Todo
* add new nvim configs

# Import Chain
* flake.nix
  * pkgs/
  * overlays/
  * modules/
  * hosts/${hostname}/configuration.nix
    * hosts/${hostname}/hardware-configuration.nix
    * common/configuration.nix
    * hosts/${hostname}/home.nix
      * common/home.nix
