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
  version = "0-unstable-2024-05-29";

  src = fetchFromGitHub {
    owner = "AaronVerDow";
    repo = "fancy-cat";
    rev = "bfa4f1da2790e84639be378c2b10715dd1407d96";
    hash = "sha256-NeTp4uhjBipBOEu36eHG4uq6ri5kZtDpz+DEdaDiHkY=";
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
