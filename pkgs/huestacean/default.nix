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
  version = "2.6";

  #src = fetchFromGitHub {
  #  owner = "BradyBrenot";
  #  repo = "huestacean";
  #  rev = "24da9fff3584f1453ef8bc032a26774e3ac8ea5a";
  #  sha256 = "0gcaw65axij912zq7ckal99310hqn4p11dc5svzai9zf9in9mbxq";
  #  fetchSubmodules = true;
  #};

  src = fetchgit {
    url = "https://github.com/BradyBrenot/huestacean.git";
    rev = "24da9fff3584f1453ef8bc032a26774e3ac8ea5a";
    sha256 = "1cw9adid6m5cbx3xy14mhr445igsnmbw4anf204k93hgpwl4l5y2";
    fetchSubmodules = true;
  };

  dontUseQmakeConfigure = true;

  nativeBuildInputs = [ cmake perl libsForQt5.qt5.wrapQtAppsHook ];

  buildInputs = [
    libsForQt5.qt5.qtbase
    libsForQt5.qt5.qtquickcontrols2
    libGL
    libX11
    libXext
    libXinerama
    libXfixes
    libXtst
  ];

  buildCommand = ''
    cp -r $src/* ./
    mkdir build
    cd build
    cmake ..
    make huestacean

    mkdir -p $out/bin
    cp huestacean $out/bin/huestacean
    wrapQtApp $out/bin/huestacean
  '';

}
