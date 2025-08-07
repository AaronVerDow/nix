{ pkgs ? import <nixpkgs> { } }:

let
  desktopCollector = { name, buildInputs ? [ ], ... } @ args:
    pkgs.stdenv.mkDerivation ({
      inherit name;
      phases = ["installPhase"];
      
      buildInputs = buildInputs;
      
      installPhase = ''
        mkdir -p $out/share
        for pkg in ${toString buildInputs}; do
          if [ -d "$pkg/share/icons" ]; then
            ${pkgs.rsync}/bin/rsync -rL --chmod=Du+w $pkg/share/icons $out/share/
          fi
          if [ -d "$pkg/share/applications" ]; then
            ${pkgs.rsync}/bin/rsync -rL --chmod=Du+w $pkg/share/applications $out/share/
          fi
          chmod -R +w "$out/share"
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
