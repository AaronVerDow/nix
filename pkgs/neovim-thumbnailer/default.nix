{
  pkgs ? import <nixpkgs> { },
}:

pkgs.stdenv.mkDerivation {
  pname = "neovim-thumbnailer";
  version = "1.0.0";

  src = ./.;

  nativeBuildInputs = with pkgs; [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin

    mkdir -p $out/share/thumbnailers
    cp ./neovim.thumbnailer $out/share/thumbnailers

    outfile=$out/bin/neovim-thumbnailer
    cp $src/neovim-thumbnailer.sh $outfile
    chmod +x $outfile
    wrapProgram $outfile --prefix PATH : ${
      pkgs.lib.makeBinPath [
        pkgs.bash
        pkgs.xterm
        pkgs.neovim
        pkgs.xorg.xwd
        pkgs.xorg.xvfb
        pkgs.xorg.xwininfo
        pkgs.imagemagick
      ]
    }

  '';
}
