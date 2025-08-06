{
  stdenv,
  lib,
  fetchFromGitHub,
  pkg-config,
  pkgs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openscad-post-processor";
  version = "0-unstable-2025-05-05";

  src = fetchFromGitHub {
    owner = "AaronVerDow";
    repo = "openscad-post-processor";
    rev = "3e00de439b54338ca9ecb55176bac5d5bbf8f48b";
    hash = "sha256-TB994Daj8lGKY4upntHBkonk30Li2rLOt2Ee4pF4cqI=";
  };

  nativeBuildInputs = [ pkg-config ];

  propagatedBuildInputs = [
    pkgs.bc
    pkgs.imagemagick
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp bin/openscad-render $out/bin/

    runHook postInstall
  '';

  meta = with lib; {
    description = "OpenSCAD post processing scripts";
    homepage = "https://github.com/AaronVerDow/openscad-post-processor";
    license = licenses.mit;
    maintainers = with maintainers; [ averdow ];
    platforms = [ "x86_64-linux" ];
  };
})
