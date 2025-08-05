{
  pkgs ? import <nixpkgs> { },
}:

pkgs.stdenv.mkDerivation {
  pname = "temp-nix-launcher";
  version = "1.0.0";

  src = ./.;

  nativeBuildInputs = with pkgs; [ makeWrapper ];
  buildInputs = with pkgs; [
    bash
    kitty
  ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src/temp-nix-launcher.sh $out/bin/temp-nix-launcher
    chmod +x $out/bin/temp-nix-launcher
    wrapProgram $out/bin/temp-nix-launcher --prefix PATH : ${
      pkgs.lib.makeBinPath [
        pkgs.bash
        pkgs.kitty
        pkgs.nix
      ]
    }
  '';
}
