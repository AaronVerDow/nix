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
  # awesomeFreedesktop = pkgs.fetchFromGitHub {
    # owner = "lcpz";
    # repo = "awesome-freedesktop";
    # rev = "c82ad2960c5f0c84e765df68554c266ea7e9464d";
    # sha256 = "sha256-IXV4YxG1hIq/LCurgbR1jEcwljRxxyVvwbEhrcJhlAk=";
  # };
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
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ./firefox.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  home = {
    username = "averdow";
    homeDirectory = "/home/averdow";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [ 
    # gui programs
    firefox
    discord
    openscad
    inkscape
    gimp
    kitty
    libreoffice
    blender
    my_numworks
    xournalpp

    # X customization
    rofi # pop up launcher
    nitrogen # set desktop background
    xcompmgr
    arc-icon-theme # battery widget
    acpi # battery widget
    ubuntu_font_family

    # utilities
    scrot # screenshot utility
    pcmanfm
    pavucontrol
    touchegg # touchscreen gestures
    onboard # onscreen keyboard
    xclip
    barrier
    volumeicon
    flashfocus
    networkmanagerapplet
    copyq
    xorg.xkill
    xrotate
    
  (writeShellScriptBin "my_run" ''
    ${pkgs.rofi}/bin/rofi -show drun -theme ~/.config/rofi/launchers/type-1/style-5.rasi
  '')

  (writeShellScriptBin "my_wallpaper" ''
    ${pkgs.nitrogen}/bin/nitrogen --set-zoom-fill ~/Pictures/wood.jpg
  '')

  (writeShellScriptBin "my_touchrun" ''
    # need to add this to dotfiles still
    ${pkgs.rofi}/bin/rofi -show drun -theme ~/.config/rofi/touchscreen/touch.rasi
  '')

  (writeShellScriptBin "calculator_toggle" ''
	pgrep epsilon && pkill epsilon || ${pkgs.my_numworks}/bin/epsilon
  '')

  ]; #  ++ [ unstable.numworks-epsilon ];

  # Enable home-manager and git
  programs.home-manager.enable = true;

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
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
  home.file.".config/awesome/rc.lua".source = ./dotfiles/dot_config/awesome/rc.lua;
  home.file.".config/touchegg/touchegg.conf".source = ./dotfiles/dot_config/touchegg/touchegg.conf;
  home.file.".config/neofetch/config.conf".source = ./dotfiles/dot_config/neofetch/config;
  home.file.".config/rofi/config.rasi".source = ./dotfiles/dot_config/rofi/config.rasi;
  home.file.".config/kitty/kitty.conf".source = ./dotfiles/dot_config/kitty/kitty.conf;
  home.file.".config/volumeicon/volumeicon".source = ./dotfiles/dot_config/volumeicon/volumeicon;
  home.file.".config/awesome/awesome-wm-widgets".source = awesomeWmWidgets;
  home.file.".config/awesome/freedesktop".source = awesomeFreedesktop;

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
