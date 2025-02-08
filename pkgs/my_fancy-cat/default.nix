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
    rev = "be4230bb3fec92a46d359a886eb198a414b907bd";
    hash = "sha256-g0BgvHyxWD8i/alVis5L8eAcIady548kcwTQAyuXptA=";
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
