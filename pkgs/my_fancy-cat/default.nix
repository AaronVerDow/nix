{
  callPackage,
  fetchFromGitHub,
  freetype,
  gumbo,
  harfbuzz,
  jbig2dec,
  lib,
  libjpeg,
  libz,
  mujs,
  mupdf,
  openjpeg,
  stdenv,
  zig,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "fancy-cat";
  version = "0-unstable-2024-05-29";

  src = fetchFromGitHub {
    owner = "AaronVerDow";
    repo = "fancy-cat";
    rev = "ddf908fbe340047ec6a202319bd9a95e0cbb1f94";
    hash = "sha256-PShUyXKUFuYg/X/Q80VwEyb05TBkHprY85lmpvOz/o0=";
  };

  patches = [ ./0001-changes.patch ];

  nativeBuildInputs = [
    zig.hook
  ];

  zigBuildFlags = [ "--release=fast" ];

  buildInputs = [
    mupdf
    harfbuzz
    freetype
    jbig2dec
    libjpeg
    openjpeg
    gumbo
    mujs
    libz
  ];

  postPatch = ''
    ln -s ${callPackage ./build.zig.zon.nix { }} $ZIG_GLOBAL_CACHE_DIR/p
  '';

  meta = {
    description = "PDF viewer for terminals using the Kitty image protocol";
    homepage = "https://github.com/freref/fancy-cat";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ ciflire ];
    mainProgram = "fancy-cat";
    inherit (zig.meta) platforms;
  };
})
