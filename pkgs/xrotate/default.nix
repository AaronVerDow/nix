{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation {
  pname = "xrotate";
  version = "1.0.0";

  src = ./.;

  nativeBuildInputs = with pkgs; [ makeWrapper ];
  buildInputs = with pkgs; [ bash xorg.xrandr xorg.xinput awesome ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/man/man1

    cp $src/xrotate.sh $out/bin/xrotate
    cp $src/man.1 $out/share/man/man1/xrotate.1

    chmod +x $out/bin/xrotate
    wrapProgram $out/bin/xrotate --prefix PATH : ${
      pkgs.lib.makeBinPath [
        pkgs.bash
        pkgs.xorg.xrandr
        pkgs.xorg.xinput
        pkgs.awesome
      ]
    }
  '';
}
