{ 
  stdenv,
  lib,
  fetchFromGitHub,
  callPackage,
  pkg-config,
  mupdf,
  harfbuzz,
  freetype,
  jbig2dec,
  libjpeg,
  openjpeg,
  gumbo,
  mujs,
  zlib,
  zig
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fancy-cat";
  version = "0-unstable-2025-09-03";

  src = fetchFromGitHub {
    owner = "freref";
    repo = "fancy-cat";
    rev = "92f2cd6907d77fa5c2e0e35697a685415d00552a";
    hash = "sha256-RbuNOivCXbJ6WmwrheIpMiEkomp3w7WAE6b44WQvwek=";
  };

  nativeBuildInputs = [ pkg-config zig ];

  deps = callPackage ./build.zig.zon.nix { };

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

  buildPhase = ''
    # Copy the source to a writable directory
    cp -r $src $TMPDIR/source
    cd $TMPDIR/source

    # Set Zig's cache directory to a writable location
    export ZIG_GLOBAL_CACHE_DIR=$TMPDIR/zig-cache

    # Run sed on the copied files
    sed -i 's/mupdf-third/mupdf/g' build.zig

    # Build the project
    # zig build --release=fast --system ${finalAttrs.deps}
    
    # Workaround for build issue https://github.com/freref/fancy-cat/issues/18
    zig build --release=fast --system ${finalAttrs.deps} -Dcpu="skylake"

  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp $TMPDIR/source/zig-out/bin/fancy-cat $out/bin/

    runHook postInstall
  '';

  meta = with lib; {
    description = "PDF viewer for terminals using the Kitty image protocol";
    homepage = "https://github.com/freref/fancy-cat";
    license = licenses.mit;
    maintainers = with maintainers; [ averdow ];
    platforms = [ "x86_64-linux" ];
  };
})
