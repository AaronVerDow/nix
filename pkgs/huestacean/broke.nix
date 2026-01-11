{ stdenv
, fetchgit
, cmake
, libsForQt5
, libGL
, libX11
, libXext
, libXinerama
, libXfixes
, libXtst
, perl
}:

stdenv.mkDerivation {
  pname = "huestacean";
  version = "0-unstable-06-19-2019";

  src = fetchgit {
    url = "https://github.com/BradyBrenot/huestacean.git";
    rev = "e72b43b66cc3b6b58554fa49ac207ad9f945c3fb";
    sha256 = "sha256-/FMsAuTbqKXkLbNuhAMBy611PCm+BhnKpKTfh6fdb+Q=";
    fetchSubmodules = true;
  };

  dontUseQmakeConfigure = true;

  nativeBuildInputs = [ 
    cmake 
    perl 
    libsForQt5.qt5.wrapQtAppsHook 
  ];

  buildInputs = [
    libsForQt5.qt5.qtbase
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtremoteobjects  # Add this missing dependency
    libGL
    libX11
    libXext
    libXinerama
    libXfixes
    libXtst
  ];

}
