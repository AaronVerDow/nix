# My NixOS Flake & Dotfiles

* AwesomeWM
* Dark mode + transparency
* Touchscreen support
  * Gestures
    * Rotate Screen
    * Open Onscreen keyboard
    * Open Launcher
* Titlebars on floating windows
* AppArmor
* Firefox customized to match AwesomeWM 

# Import Chain

* flake.nix
  * pkgs/
  * overlays/
  * modules/
  * hosts/${hostname}/configuration.nix
    * hosts/${hostname}/hardware-configuration.nix
    * common/configuration.nix
      * common/apparmor/
    * common/x/configuration.nix
    * hosts/${hostname}/home.nix
      * common/home.nix
        * nvim/nvim.nix
        * prose/prose.nix
      * common/x/home.nix
        * firefox/firefox.nix
