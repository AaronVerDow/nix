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
  * Key chord to disable built in laptop keyboard so a Bluetooth keyboard can be placed on top
* Desktop launchers that can load rarely used programs on the fly using Nix
* AppArmor (experimental)
* Personal binary cache for building packages, served through Tailscale
* Shell:
  * Show onefetch when entering a new git repository 
  * ls when entering a directory
  * Eternal bash history
* CAD development:
  * Render scripts for OpenSCAD
  * Automatically open previews when editing OpenSCAD scripts
* Writing:
  * Rendering scripts for Bookdown and LaTeX
  * Git aware word count graph for Bookdown projects
  * Bones Writer - simple writer with no editing capacity for writing in a flow state
  * Command line PDF viewer

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
