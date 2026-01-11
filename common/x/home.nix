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
    ./firefox/firefox.nix
    inputs.spicetify-nix.homeManagerModules.default
  ];

  # allow fonts to be used from package list
  fonts.fontconfig.enable = true;

  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      enable = true;
      # https://github.com/Gerg-L/spicetify-nix/blob/master/docs/themes.md
      theme = spicePkgs.themes.lucid;
      enabledCustomApps = with spicePkgs.apps; [
        newReleases
      ];
    };

  home.packages = lib.mkMerge [
    (with pkgs; [
      # Creative & Design Applications
      my_openscad # Programmatic CAD modeling
      openscad-post-processor

      # Office & Productivity
      (discord.override {
        withOpenASAR = true;
        withVencord = true;
        vencord = vencord;
      })
      my_numworks # Calculator
      onlyoffice-desktopeditors # Office suite
      gimp

      # Terminal & System Utilities
      arandr # Screen layout configuration
      my_camset # Camera settings utility
      copyq # Clipboard manager
      kitty # Terminal emulator
      mlterm # Alternative terminal
      wavemon # Wireless monitoring
      xclip # Clipboard manager
      xorg.xkill # X11 window killer

      # System Monitoring & Control
      acpi # Battery information
      networkmanagerapplet
      pwvucontrol # Audio control
      volumeicon # Volume control

      # Window Management & Desktop Environment
      flashfocus # Focus animations
      nitrogen # Wallpaper manager
      picom
      rofi # Application launcher

      # barrier # switch to input leap?
      unstable.restream
      restream-desktop # Desktop entry for restream preview

      # Screenshot & Screen Capture
      scrot # Screenshot utility
      xfce.xfce4-screenshooter

      # Fonts & Themes
      arc-icon-theme # Icon theme
      sweet-folders
      candy-icons
      courier-prime
      libertine
      merriweather
      ubuntu-classic
      iosevka
      b612
      victor-mono
      google-fonts

      flatpak
      gamemode
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

      (writeShellScriptBin "my_run" ''
        ${pkgs.rofi}/bin/rofi -show drun -theme ~/.config/rofi/launchers/type-1/style-5.rasi
      '')

      (writeShellScriptBin "wallpaper_set" ''
        ${pkgs.nitrogen}/bin/nitrogen ~/.config/wallpaper --set-zoom-fill --head=0
        ${pkgs.nitrogen}/bin/nitrogen ~/.config/wallpaper --set-zoom-fill --head=1 || true
        ${pkgs.nitrogen}/bin/nitrogen ~/.config/wallpaper --set-zoom-fill --head=2 || true
      '')

      (writeShellScriptBin "wallpaper_rotate" ''
        ln -sf $( find ~/git/wallpapers/pics -type f | shuf -n 1 ) ~/.config/wallpaper
        set_wallpaper
      '')

      (nix-run-desktop.launcher {
        nativeBuildInputs = [ blender ];
        copy_icons = false;
      })
      (nix-run-desktop.launcher {
        nativeBuildInputs = [ inkscape ];
        copy_icons = false;
      })
      (nix-run-desktop.launcher {
        nativeBuildInputs = [ freecad ];
        copy_icons = false;
      })
      (nix-run-desktop.launcher {
        nativeBuildInputs = [ obs-studio ];
        copy_icons = false;
      })
      (nix-run-desktop.launcher {
        nativeBuildInputs = [ drawing ];
      })
      (nix-run-desktop.launcher {
        nativeBuildInputs = [ via ];
      })
      (nix-run-desktop.launcher {
        nativeBuildInputs = [ tor-browser ];
        copy_icons = false;
      })
      (nix-run-desktop.launcher {
        nativeBuildInputs = [ chromium ];
        copy_icons = false;
      })
      (nix-run-desktop.launcher {
        nativeBuildInputs = [ openshot-qt ];
        copy_icons = false;
      })
    ])
  ];

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  home.pointerCursor = {
    package = pkgs.volantes-cursors;
    name = "volantes_cursors";
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Sweet-Rainbow";
      # name = "candy-icons";
      package = pkgs.sweet-folders;
      # package = pkgs.candy-icons;
    };
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
    ".config/rofi/config.rasi".source = ../dotfiles/dot_config/rofi/config.rasi;
    ".config/kitty/kitty.conf".source = ../dotfiles/dot_config/kitty/kitty.conf;
    ".config/volumeicon/volumeicon".source = ../dotfiles/dot_config/volumeicon/volumeicon;
    ".config/Vencord/themes/ClearVision-v7-Sapphire-Vencord.css".source =
      ../dotfiles/dot_config/Vencord/themes/ClearVision-v7-Sapphire-Vencord.css;
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
