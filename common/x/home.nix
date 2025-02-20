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

  home.packages = lib.mkMerge [ (with pkgs; [
    # gui programs
    discord
    openscad
    inkscape
    gimp
    kitty
    blender
    my_numworks
    drawing
    onlyoffice-bin
    jetbrains.idea-ultimate
    unstable.via
    camset

    mlterm
    merriweather
    libre-baskerville
    courier-prime
    libertine

    # X customization
    rofi # pop up launcher
    nitrogen # set desktop background
    arc-icon-theme # battery widget
    acpi # battery widget
    ubuntu_font_family

    # utilities
    picom-pijulius
    scrot # screenshot utility
    xfce.xfce4-screenshooter
    pcmanfm
    pwvucontrol
    touchegg # touchscreen gestures
    onboard # onscreen keyboard
    xclip
    barrier
    volumeicon
    flashfocus
    networkmanagerapplet
    copyq
    xorg.xkill
    xrotate # custom rotation package
    wavemon
    arandr

    (writeShellScriptBin "my_run" ''
      ${pkgs.rofi}/bin/rofi -show drun -theme ~/.config/rofi/launchers/type-1/style-5.rasi
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

    (writeShellScriptBin "my_touchrun" ''
      # need to add this to dotfiles still
      ${pkgs.rofi}/bin/rofi -show drun -theme ~/.config/rofi/touchscreen/touch.rasi
    '')

    (writeShellScriptBin "calculator_toggle" ''
      pgrep epsilon && pkill epsilon || ${pkgs.my_numworks}/bin/epsilon
    '')

    (writeShellScriptBin "onboard_toggle" ''
      dbus-send --type=method_call --print-reply --dest=org.onboard.Onboard /org/onboard/Onboard/Keyboard org.onboard.Onboard.Keyboard.ToggleVisible
    '')
  ])];

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
    categories = [ "Network" "WebBrowser" ];
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

  home.file.".config/picom/picom.conf".source = ../dotfiles/dot_config/picom/picom.conf;
  home.file.".config/awesome/rc.lua".source = ../dotfiles/dot_config/awesome/rc.lua;
  home.file.".config/touchegg/touchegg.conf".source = ../dotfiles/dot_config/touchegg/touchegg.conf;
  home.file.".config/rofi/config.rasi".source = ../dotfiles/dot_config/rofi/config.rasi;
  home.file.".config/rofi/touchscreen".source = ../dotfiles/dot_config/rofi/touchscreen;
  home.file.".config/kitty/kitty.conf".source = ../dotfiles/dot_config/kitty/kitty.conf;
  home.file.".config/volumeicon/volumeicon".source = ../dotfiles/dot_config/volumeicon/volumeicon;
  home.file.".local/share/onboard/layouts/full.onboard".source = ../dotfiles/dot_local/share/onboard/layouts/full.onboard;

  home.activation.copyRofiConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
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
