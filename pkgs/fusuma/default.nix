{ stdenv, bundlerEnv, ruby, libinput }:
let
  gems = bundlerEnv {
    name = "your-package";
    inherit ruby;
    gemdir  = ./.;
  };
in stdenv.mkDerivation {
  name = "your-package";
  src = ./.;
  buildInputs = [gems ruby libinput];
  installPhase = ''
    mkdir -p $out
    cp -r $src $out
  '';
}
