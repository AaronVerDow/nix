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

let
  rofiConfig = builtins.fetchGit {
    url = "https://github.com/adi1090x/rofi.git";
    rev = "3a28753b0a8fb666f4bd0394ac4b0e785577afa2";
  };
in
{
  imports = [
    ./dconf/onboard.nix
    ./firefox/firefox.nix
  ];

  # allow fonts to be used from package list
  fonts.fontconfig.enable = true;

  home.packages = lib.mkMerge [
    (with pkgs; [
      # Development Tools
      unstable.code-cursor
      satisfactory-file-parser # TypeScript parser for Satisfactory save/blueprint files
      nixxrun
      nixxrun-entries

      # Creative & Design Applications
      openscad # Programmatic CAD modeling
      openscad-post-processor

      # Office & Productivity
      discord # Communication platform
      my_numworks # Calculator
      onlyoffice-bin # Office suite

      # Terminal & System Utilities
      arandr # Screen layout configuration
      my_camset # Camera settings utility
      copyq # Clipboard manager
      kitty # Terminal emulator
      mlterm # Alternative terminal
      wavemon # Wireless monitoring
      xclip # Clipboard manager
      xorg.xkill # X11 window killer
      xrotate # Custom rotation package

      # System Monitoring & Control
      acpi # Battery information
      networkmanagerapplet
      pwvucontrol # Audio control
      volumeicon # Volume control

      # Window Management & Desktop Environment
      flashfocus # Focus animations
      nitrogen # Wallpaper manager
      # picom-pijulius # Compositor
      picom
      rofi # Application launcher

      # File Management
      pcmanfm # File manager

      # Input & Accessibility
      barrier
      onboard # On-screen keyboard
      touchegg # Touchscreen gestures
      unstable.restream
      restream-desktop # Desktop entry for restream preview

      # Screenshot & Screen Capture
      scrot # Screenshot utility
      xfce.xfce4-screenshooter

      # Fonts & Themes
      arc-icon-theme # Icon theme
      courier-prime
      libre-baskerville
      libertine
      merriweather
      ubuntu_font_family

      # Games
      flatpak

      vlc

      (writeShellScriptBin "calculator_toggle" ''
        # Launch calculator or toggle visibility if running
        if ! ${pkgs.xdotool}/bin/xdotool search --name "Epsilon" > /dev/null; then
          ${pkgs.my_numworks}/bin/epsilon &
        fi
        WINDOW_ID=$(${pkgs.xdotool}/bin/xdotool search --name "Epsilon")
        if ${pkgs.xorg.xwininfo}/bin/xwininfo -id "$WINDOW_ID" | grep -q "Map State: IsViewable"; then
          ${pkgs.xdotool}/bin/xdotool windowminimize "$WINDOW_ID"
        else
          ${pkgs.xdotool}/bin/xdotool windowmap "$WINDOW_ID"
          ${pkgs.xdotool}/bin/xdotool windowactivate "$WINDOW_ID"
        fi
      '')

      (writeShellScriptBin "cursor-detached" ''
        # Find git repo root if it exists
        GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
        if [ -n "$GIT_ROOT" ]; then
          cd "$GIT_ROOT"
          # CLI args are not passed properly through NixOS wrapper
          ${pkgs.unstable.code-cursor}/bin/cursor "$GIT_ROOT" "$@" &> /dev/null &
        else
          ${pkgs.unstable.code-cursor}/bin/cursor "$@" &> /dev/null &
        fi
        disown
      '')

      (writeShellScriptBin "my_run" ''
        ${pkgs.rofi}/bin/rofi -show drun -theme ~/.config/rofi/launchers/type-1/style-5.rasi
      '')

      (writeShellScriptBin "my_touchrun" ''
        # need to add this to dotfiles still
        ${pkgs.rofi}/bin/rofi -show drun -theme ~/.config/rofi/touchscreen/touch.rasi
      '')

      (writeShellScriptBin "onboard_toggle" ''
        dbus-send --type=method_call --print-reply --dest=org.onboard.Onboard /org/onboard/Onboard/Keyboard org.onboard.Onboard.Keyboard.ToggleVisible
      '')

      (writeShellScriptBin "set_wallpaper" ''
        ${pkgs.nitrogen}/bin/nitrogen ~/.config/wallpaper --set-zoom-fill --head=0
        ${pkgs.nitrogen}/bin/nitrogen ~/.config/wallpaper --set-zoom-fill --head=1 || true
        ${pkgs.nitrogen}/bin/nitrogen ~/.config/wallpaper --set-zoom-fill --head=2 || true
      '')

      (writeShellScriptBin "wallpaper" ''
        ln -sf $( find ~/git/wallpapers/pics -type f | shuf -n 1 ) ~/.config/wallpaper
        set_wallpaper
      '')
    ])
  ];

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  # Install this as needed
  xdg.desktopEntries.chromium-nix = {
    name = "Chromium (Nix Shell)";
    comment = "Open Chromium browser in a Nix shell";
    exec = "nix-shell -p chromium --run chromium-browser";
    icon = "web-browser";
    terminal = false;
    type = "Application";
    categories = [
      "Network"
      "WebBrowser"
    ];
  };

  home.pointerCursor = {
    package = pkgs.volantes-cursors;
    name = "volantes_cursors";
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    # firefox uses GTK3 and may have an extra border
    gtk3.extraCss = ''
      .window-frame {
          box-shadow: 0 0 0 0;
          margin: 0;
      }
      window decoration {
          margin: 0;
          padding: 0;
          border: none;
      }
    '';
  };

  home.file = {
    ".config/picom/picom.conf".source = ../dotfiles/dot_config/picom/picom.conf;
    ".config/awesome/rc.lua".source = ../dotfiles/dot_config/awesome/rc.lua;
    ".config/touchegg/touchegg.conf".source = ../dotfiles/dot_config/touchegg/touchegg.conf;
    ".config/rofi/config.rasi".source = ../dotfiles/dot_config/rofi/config.rasi;
    ".config/rofi/touchscreen".source = ../dotfiles/dot_config/rofi/touchscreen;
    ".config/kitty/kitty.conf".source = ../dotfiles/dot_config/kitty/kitty.conf;
    ".config/volumeicon/volumeicon".source = ../dotfiles/dot_config/volumeicon/volumeicon;
    ".local/share/onboard/layouts/full.onboard".source =
      ../dotfiles/dot_local/share/onboard/layouts/full.onboard;
    ".local/share/onboard/layouts/full.svg".source =
      ../dotfiles/dot_local/share/onboard/layouts/full.svg;
  };

  home.activation.copyRofiConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ~/.config/rofi
    chmod +w -R ~/.config/rofi # this allows the next copy to function
    ${pkgs.rsync}/bin/rsync -av --exclude 'config.rasi' ${rofiConfig}/files/ ~/.config/rofi/
    chmod +w ~/.config/rofi # this allows the config from dotfiles to be written
    mkdir -p ~/.local/share/fonts
    cp -f ${rofiConfig}/fonts/* ~/.local/share/fonts/
  '';

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
