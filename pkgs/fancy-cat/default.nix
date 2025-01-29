{ 
  stdenv,
  lib,
  fetchFromGitHub,
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

stdenv.mkDerivation {
  pname = "fancy-cat";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "freref";
    repo = "fancy-cat";
    rev = "6a651ae9f3700c1b176734ddf1dd369d82cb6fbc";
    hash = "sha256-rEdCxHoG7nQE0ejkpbp4flOK5qYHPKB5yrtFQqCjM6k=";
  };

  nativeBuildInputs = [ pkg-config zig ];

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
    cd $src
    sed -i 's/mupdf-third/mupdf/g' build.zig

    zig build --fetch
    zig build --release=fast
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp $src/zig-out/bin/fancy-cat $out/bin/

    runHook postInstall
  '';

  meta = with lib; {
    description = "PDF viewer for terminals using the Kitty image protocol";
    homepage = "https://github.com/freref/fancy-cat";
    license = licenses.mit;
    maintainers = with maintainers; [ averdow ];
    platforms = [ "x86_64-linux" ];
  };
}
