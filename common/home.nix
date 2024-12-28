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
  awesomeWmWidgets = pkgs.fetchFromGitHub {
    owner = "streetturtle";
    repo = "awesome-wm-widgets";
    rev = "df6bc4a260158fdc6e2678f1bb281f442d7887ac";
    sha256 = "sha256-IXV4YxG1hIq/LCurgbR1jEcwljRxxyVvwbEhrcJhlAk=";
  };
  awesomeFreedesktop = builtins.fetchGit {
    url = "https://github.com/lcpz/awesome-freedesktop.git";
    rev = "c82ad2960c5f0c84e765df68554c266ea7e9464d";
  };
  rofiConfig = builtins.fetchGit {
    url = "https://github.com/adi1090x/rofi.git";
    rev = "3a28753b0a8fb666f4bd0394ac4b0e785577afa2"; 
  };
in
{
  imports = [
    ./nvim.nix
    ./dconf/onboard.nix
    ./firefox/firefox.nix
    ./prose/prose.nix
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = "averdow";
    homeDirectory = "/home/averdow";
  };

  # allow fonts to be used from package list
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [ 
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
    via # configure QMK keyboards
    evince # read PDF files
    wavemon
    arandr
    texliveFull

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

    (writeShellScriptBin "my_ping" ''
      gateway=$( ip route | grep default | awk '{ print $3}' )
      sudo ${pkgs.liboping}/bin/noping $gateway modem public
    '')

    (writeShellScriptBin "pkg" ''
      nom shell nixpkgs#$1
    '')
  ];

  programs.home-manager.enable = true;

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

  programs.git = {
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    userName = "Aaron VerDow";
    userEmail = "aaron@verdow.com";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";


  # hacky solution until I find a proper home for this, typically goes in /etc/ so root is impacted as well
  home.file.".bash.bashrc".source = ./dotfiles/dot_bash.bashrc;
  # should be in /etc/DIR_COLORS ?
  home.file.".dir_colors".source = ./dotfiles/dot_dir_colors;
  home.file.".bashrc".source = ./dotfiles/dot_bashrc;
  home.file.".config/picom/picom.conf".source = ./dotfiles/dot_config/picom/picom.conf;
  home.file.".config/awesome/rc.lua".source = ./dotfiles/dot_config/awesome/rc.lua;
  home.file.".config/touchegg/touchegg.conf".source = ./dotfiles/dot_config/touchegg/touchegg.conf;
  home.file.".config/neofetch/config.conf".source = ./dotfiles/dot_config/neofetch/config;
  home.file.".config/rofi/config.rasi".source = ./dotfiles/dot_config/rofi/config.rasi;
  home.file.".config/kitty/kitty.conf".source = ./dotfiles/dot_config/kitty/kitty.conf;
  home.file.".config/volumeicon/volumeicon".source = ./dotfiles/dot_config/volumeicon/volumeicon;
  home.file.".local/share/onboard/layouts/full.onboard".source = ./dotfiles/dot_local/share/onboard/layouts/full.onboard;
  home.file.".config/awesome/awesome-wm-widgets".source = awesomeWmWidgets;

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
