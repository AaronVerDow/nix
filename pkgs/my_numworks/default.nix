{ stdenv
, lib
, fetchFromGitHub
, libpng
, libjpeg
, freetype
, xorg
, python3
, imagemagick
, gcc-arm-embedded
, pkg-config
, python3Packages
, makeDesktopItem
, copyDesktopItems
}:

stdenv.mkDerivation rec {
  pname = "numworks-epsilon";
  version = "22.2.0";

  src = fetchFromGitHub {
    owner = "numworks";
    repo = "epsilon";
    rev = version;
    hash = "sha256-E2WaXTn8+Ky9kdZxvQmEt63Ggo6Ns0fZ0Za+rQGIMSg=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    libpng
    libjpeg
    freetype
    xorg.libXext
    python3
    imagemagick
    gcc-arm-embedded
    python3Packages.lz4
    copyDesktopItems
  ];

  makeFlags = [
    "PLATFORM=simulator"
  ];

  installPhase = ''
    runHook preInstall

    mv ./output/release/simulator/linux/{epsilon.bin,epsilon}
    mkdir -p $out/bin
    cp -r ./output/release/simulator/linux/* $out/bin/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Simulator for Epsilon, a High-performance graphing calculator operating system";
    homepage = "https://numworks.com/";
    license = licenses.cc-by-nc-sa-40;
    maintainers = with maintainers; [ erikbackman ];
    platforms = [ "x86_64-linux" ];
  };

  postInstall = ''
    # not working currently, cannot find numworks.png
    # install -Dm644 $src/numworks.png $out/share/icons/hicolor/48x48/apps/numworks.png
  '';

  desktopItems = [
   (makeDesktopItem {
      name = "Epsilon";
      exec = "epsilon";
      icon = "accessories-calculator";
      desktopName = "Epsilon Calculator";
      comment = "A powerful calculator";
      categories = [ "Utility" ];
    })
    ];
}
