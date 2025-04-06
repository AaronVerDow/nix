{ 
  stdenv,
  lib,
  fetchFromGitHub,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openscad-post-processor";
  version = "0-unstable-2025-05-05";

  src = fetchFromGitHub {
    owner = "AaronVerDow";
    repo = "openscad-post-processor";
    rev = "385b836479021bbe19288c445cd39282b6249ee4";
    hash = "sha256-0iBoyUY2Au+LYmhGCDLjDNeOUIVNffcZ9hlbKXigjL0=";
  };

  nativeBuildInputs = [ pkg-config ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp bin/openscad-render $out/bin/
    cp bin/openscad-preview $out/bin/

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
