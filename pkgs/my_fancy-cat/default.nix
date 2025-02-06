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
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "AaronVerDow";
    repo = "fancy-cat";
    rev = "52079ad314ddddd78875c7b8b61e3272936e317f";
    hash = "sha256-wtS4bby+kcSpfbMEyARANJOcXhBAL5osTsBGvu33NnU=";
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
    zig build --fetch --system ${finalAttrs.deps}
    zig build --release=fast --system ${finalAttrs.deps}
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
