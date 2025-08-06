{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
}:

let
  desktopCollector = {
    name,
    buildInputs ? [],
    ...
  } @ args:
    pkgs.stdenv.mkDerivation ({
      inherit name;
      phases = ["installPhase"];
      
      buildInputs = args.buildInputs or [];
      
      installPhase = ''
        mkdir -p $out/share
        for pkg in ${toString buildInputs}; do
          if [ -d "$pkg/share/icons" ]; then
            mkdir -p $out/share/icons
            cp -r "$pkg/share/icons/"* $out/share/icons/
          fi
          if [ -d "$pkg/share/applications" ]; then
            mkdir -p $out/share/applications
            cp -r "$pkg/share/applications/"* $out/share/applications/
          fi
        done
      '';
    } // removeAttrs args ["buildInputs"]);
in

pkgs.stdenv.mkDerivation {
  pname = "nixxrun";
  version = "1.0.0";

  src = ./.;

  nativeBuildInputs = with pkgs; [ makeWrapper ];
  buildInputs = with pkgs; [
    bash
    kitty
  ];

  dontBuild = true;

  installPhase = ''
    # Install binary
    mkdir -p $out/bin
    cp $src/nixxrun.sh $out/bin/nixxrun
    chmod +x $out/bin/nixxrun
    wrapProgram $out/bin/nixxrun --prefix PATH : ${
      pkgs.lib.makeBinPath [
        pkgs.bash
        pkgs.kitty
        pkgs.nix
      ]
    }

  '';
}
