# My NixOS Flake & Dotfiles

* AwesomeWM
* Dark mode + transparency
* Touchscreen support
  * Gestures
    * Rotate Screen
    * Open Onscreen keyboard
    * Open Launcher
* Titlebars on floating windows
* Firefox customized to match AwesomeWM 
* Sticky wallpaper rotator
* Neovim as IDE
* Custom thumbnail generators
  * xcf
  * stl
  * scad
  * pdf
  * webm
  * text file previews, with syntax highlighting
* Pop up scientific calculator
* Customized key input
  * Hold ; for vim keybindings
  * Disable built in laptop keyboard so a Bluetooth keyboard can be placed on top
* Desktop launchers that can load rarely used programs on the fly using Nix
* AppArmor (experimental)
* Personal binary cache for building packages, served through Tailscale

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

Testing Jenkins.
