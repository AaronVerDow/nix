{ zig2nix, stdenv, zig, pkg-config, mupdf, harfbuzz, freetype, jbig2dec, libjpeg, openjpeg, gumbo, mujs, zlib }:

# Suggested by deepseek; I cannot follow the documentation in the github.  This may not exist.
zig2nix.buildZigPackage {
  pname = "fancy-cat";
  version = "0.0.1";

  src = ./.;

  nativeBuildInputs = [ zig pkg-config ];

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

  meta = {
    description = "PDF viewer for terminals using the Kitty image protocol";
    homepage = "https://github.com/freref/fancy-cat";
    license = stdenv.lib.licenses.mit;
  };
}
