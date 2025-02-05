{
  lib,
  fetchFromGitHub,
  stdenv,
  zig_0_13,
  callPackage,
  mupdf,
  harfbuzz,
  freetype,
  jbig2dec,
  libjpeg,
  openjpeg,
  gumbo,
  mujs,
  zlib
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fancy-cat";
  version = "0.0.1";

  src = fetchFromGitHub {
    # owner = "freref";
    # repo = "fancy-cat";
    # rev = "6a651ae9f3700c1b176734ddf1dd369d82cb6fbc";
    # hash = "sha256-rEdCxHoG7nQE0ejkpbp4flOK5qYHPKB5yrtFQqCjM6k=";

    owner = "AaronVerDow";
    repo = "fancy-cat";
    rev = "fcb812efd294b332ad65698b22a217ec3b5854a1";
    hash = "sha256-rEdCxHoG7nQE0ejkpbp4flOK5qYHPKB5yrtFQqCjM6k=";
  };

  postPatch = ''
    ln -s ${callPackage ./build.zig.zon.nix { }} $ZIG_GLOBAL_CACHE_DIR/p
  '';

  buildInputs = [
    mupdf
    harfbuzz
    freetype
    jbig2dec
    libjpeg
    openjpeg
    gumbo
    mujs
    zlib
  ];

  nativeBuildInputs = [
    zig_0_13.hook
  ];

  env.VERSION = finalAttrs.version;

  meta = with lib; {
    description = "PDF viewer for terminals using the Kitty image protocol";
    homepage = "https://github.com/freref/fancy-cat";
    license = licenses.mit;
    maintainers = with maintainers; [ averdow ];
    platforms = [ "x86_64-linux" ];
  };
})
