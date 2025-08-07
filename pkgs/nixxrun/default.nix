{ pkgs ? import <nixpkgs> { } }:

let
  desktopCollector = { name, buildInputs ? [ ], ... } @ args:
    pkgs.stdenv.mkDerivation ({
      inherit name;
      phases = ["installPhase"];
      
      buildInputs = buildInputs;
      
      installPhase = ''
        set -x
        tmp=$( mktemp -d )
        for pkg in ${toString buildInputs}; do
          mkdir -p $tmp/share
          if [ -d "$pkg/share/icons" ]; then
            ${pkgs.rsync}/bin/rsync -rL --chmod=Du+w $pkg/share/icons $tmp/share
          fi
          if [ -d "$pkg/share/applications" ]; then
            ${pkgs.rsync}/bin/rsync -rL --chmod=Du+w $pkg/share/applications $tmp/share
          fi

          # rename files here 

          mkdir -p $out/share
          ${pkgs.rsync}/bin/rsync -r $tmp/share/* $out/share
          rm -r $tmp/share/*
        done
      '';
    } // (removeAttrs args ["buildInputs"]));
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

  passthru = {
    desktopCollector = args: desktopCollector args;
  };
}
