{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  webpthumbs = pkgs.writeShellScriptBin "webpthumbs" ''
    # I think I may be missing a library
    if tempfile=$(mktemp) && ${pkgs.libwebp}/bin/webpmux -get frame 1 "$1" -o "$tempfile"; then
      ${pkgs.imagemagick}/bin/convert -thumbnail "''${3:-256}" "$tempfile" "$2"
    else
      ${pkgs.imagemagick}/bin/convert -thumbnail "''${3:-256}" "$1" "$2"
    fi
    [ -f "$tempfile" ] && rm "$tempfile"
  '';
  thumbs-openscad = pkgs.writeShellScriptBin "thumbs-openscad" ''
    echo "$0 $@" >> /tmp/thumbs
    ${pkgs.openscad}/bin/openscad $1 --viewall --colorscheme "Tomorrow Night" --autocenter --imgsize $3,$3 -o $2 &>> /tmp/thumbs
  '';
in
{
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  programs.steam.enable = true;
  services.touchegg.enable = true;
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.cups-brother-hll2340dw ];

  services.xserver.enable = true;
  hardware.graphics.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.windowManager.awesome = {
    enable = true;
    luaModules = with pkgs.luaPackages; [
      awesome-wm-widgets
    ];
  };
  services.redshift.enable = true;
  services.flatpak.enable = true;

  environment.systemPackages = with pkgs; [
    # Thumbnailer packages
    ffmpeg-headless
    ffmpegthumbnailer
    imagemagick
    ghostscript # required by imagemagick to convert pdf files

    # https://docs.xfce.org/xfce/tumbler/available_plugins#customized_thumbnailer_for_text-based_documents
    (pkgs.writeTextDir "share/thumbnailers/imagemagick-webp.thumbnailer" ''
      [Thumbnailer Entry]
      TryExec=${webpthumbs}/bin/webpthumbs
      Exec=${webpthumbs}/bin/webpthumbs %i %o %s
      MimeType=image/webp;
    '')

    (pkgs.writeTextDir "share/thumbnailers/imagemagick-pdf.thumbnailer" ''
      [Thumbnailer Entry]
      TryExec=${pkgs.imagemagick}/bin/convert
      Exec=${pkgs.imagemagick}/bin/convert %i[0] -background "#FFFFFF" -flatten -thumbnail %s %o
      MimeType=application/pdf;application/x-pdf;image/pdf;
    '')

    (pkgs.writeTextDir "share/thumbnailers/openscad-scad.thumbnailer" ''
      [Thumbnailer Entry]
      Exec=${thumbs-openscad}/bin/thumbs-openscad %i %o %s
      MimeType=application/x-openscad;
    '')

    (pkgs.writeTextDir "share/mime/packages/openscad.xml" ''
      <?xml version="1.0" encoding="UTF-8"?>
      <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
        <mime-type type="application/x-openscad">
          <comment>OpenSCAD 3D model</comment>
          <glob pattern="*.scad"/>
          <sub-class-of type="text/plain"/>
        </mime-type>
      </mime-info>
    '')
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # recommended for audio
  security.rtkit.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  hardware.keyboard.qmk.enable = true;

  services.solaar = {
    enable = true;
    package = pkgs.solaar;
    window = "hide"; # hide startup window
    batteryIcons = "regular";
    # batteryIcons = "symbolic";
    # batteryIcons = "solaar";
    extraArgs = "";
  };
}
