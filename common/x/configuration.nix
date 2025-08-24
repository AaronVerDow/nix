{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  thumbs-webp = pkgs.writeShellScriptBin "thumbs-webp" ''
    echo "$0 $@" >> /tmp/thumbs
    if tempfile=$(mktemp) && ${pkgs.libwebp}/bin/webpmux -get frame 1 "$1" -o "$tempfile"; then
      ${pkgs.imagemagick}/bin/convert -thumbnail "''${3:-256}" "$tempfile" "$2" &>> /tmp/thumbs
    else
      ${pkgs.imagemagick}/bin/convert -thumbnail "''${3:-256}" "$1" "$2" &>> /tmp/thumbs
    fi
    [ -f "$tempfile" ] && rm "$tempfile"
  '';
  thumbs-openscad = pkgs.writeShellScriptBin "thumbs-openscad" ''
    set -euo pipefail

    INPUT=$1
    OUTPUT=$2
    SIZE=$3

    TEMP=$(mktemp --directory --tmpdir tumbler-stl-XXXXXX) || exit 1
    ${pkgs.openscad}/bin/openscad $INPUT --viewall --colorscheme "Tomorrow Night" --autocenter --imgsize "$SIZE,$SIZE" -o "$TEMP/scad.png" 
    ${pkgs.imagemagick}/bin/magick "$TEMP/scad.png" -transparent "#1d1f21" "$OUTPUT"
    rm -rf "$TEMP"
  '';
  thumbs-stl = pkgs.writeShellScriptBin "thumbs-stl" ''
    if (($# < 3)); then
      echo "$0: input_file_name output_file_name size"
      exit 1
    fi
     
    INPUT_FILE=$1
    OUTPUT_FILE=$2
    SIZE=$3
     
    TEMP=$(mktemp --directory --tmpdir tumbler-stl-XXXXXX) || exit 1
    cp "$INPUT_FILE" "$TEMP/source.stl"
    echo 'import("source.stl", convexity=10);' > "$TEMP/thumbnail.scad"
    ${pkgs.openscad}/bin/openscad --viewall --autocenter --imgsize "$SIZE,$SIZE" -o "$TEMP/scad.png" "$TEMP/thumbnail.scad"
    ${pkgs.imagemagick}/bin/magick "$TEMP/scad.png" -transparent "#FFFFE5" "$OUTPUT_FILE"
    rm -rf "$TEMP"
  '';
  thumbs-text = pkgs.writeShellScriptBin "thumbs-text" ''
    INPUT=$1
    OUTPUT=$2
    SIZE=$3
    POINTSIZE=$((SIZE/50))
    echo "$0 $@" >> /tmp/thumbs

    tempFile=$(mktemp) && {
      head -n 50 "$INPUT" > "$tempFile"
      ${pkgs.imagemagick}/bin/convert -size "''${SIZE}x$SIZE" -background black -pointsize $POINTSIZE -border $POINTSIZE -bordercolor black -fill white caption:@"$tempFile" "$OUTPUT"
      rm "$tempFile"
    }
  '';
  thumbs-xcf = pkgs.writeShellScriptBin "thumbs-xcf" ''
    INPUT=$1
    OUTPUT=$2
    SIZE=$3

    ${pkgs.gimp}/bin/gimp -i -d -f -s -b - <<EOF
    (let* ((in  "$INPUT")
           (out "$OUTPUT")
           (size $SIZE)
           (img  (car (gimp-file-load RUN-NONINTERACTIVE in in)))
           (w    (car (gimp-image-width  img)))
           (h    (car (gimp-image-height img)))
           (scale (if (> w h) (/ size w) (/ size h)))
           (neww (inexact->exact (ceiling (* w scale))))
           (newh (inexact->exact (ceiling (* h scale))))
           (layer (car (gimp-image-merge-visible-layers img CLIP-TO-IMAGE))))
      (gimp-image-scale img neww newh)
      ;; file-png-save: (run-mode image drawable filename raw-filename
      ;;                        interlace compression bkgd gama offs phys time)
      (file-png-save RUN-NONINTERACTIVE img layer out out
                     0         ; interlace off
                     9         ; compression (0..9)
                     0 0 0 0 0 ; no extra chunks
      )
      (gimp-image-delete img)
    )
    (gimp-quit 0)
    EOF
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

    # this never fires for some reason
    (pkgs.writeTextDir "share/thumbnailers/imagemagick-webp.thumbnailer" ''
      [Thumbnailer Entry]
      Exec=${thumbs-webp}/bin/thumbs-webp %i %o %s
      MimeType=image/webp;
    '')

    (pkgs.writeTextDir "share/thumbnailers/imagemagick-pdf.thumbnailer" ''
      [Thumbnailer Entry]
      TryExec=${pkgs.imagemagick}/bin/convert
      Exec=${pkgs.imagemagick}/bin/convert %i[0] -background "#FFFFFF" -flatten -thumbnail %s %o
      MimeType=application/pdf;application/x-pdf;image/pdf;
    '')

    (pkgs.writeTextDir "share/thumbnailers/imagemagick-text.thumbnailer" ''
      [Thumbnailer Entry]
      Exec=${thumbs-text}/bin/thumbs-text %i %o %s
      MimeType=text/plain;text/html;text/css;
    '')

    (pkgs.writeTextDir "share/thumbnailers/openscad-stl.thumbnailer" ''
      [Thumbnailer Entry]
      Exec=${thumbs-stl}/bin/thumbs-stl %i %o %s
      MimeType=model/stl;
    '')

    (pkgs.writeTextDir "share/thumbnailers/openscad-scad.thumbnailer" ''
      [Thumbnailer Entry]
      Exec=${thumbs-openscad}/bin/thumbs-openscad %i %o %s
      MimeType=application/x-openscad;
    '')

    (pkgs.writeTextDir "share/thumbnailers/gimp-xcf.thumbnailer" ''
      [Thumbnailer Entry]
      Exec=${thumbs-xcf}/bin/thumbs-xcf %i %o %s
      MimeType=image/x-xcf;
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
