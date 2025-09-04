{
  fetchgit,
  lib,
  stdenv,
  cmake,
  bison,
  flex,
  eigen,
  boost,
  libGLU,
  libGL,
  glew,
  opencsg,
  cgal,
  mpfr,
  gmp,
  glib,
  pkg-config,
  harfbuzz,
  gettext,
  freetype,
  fontconfig,
  double-conversion,
  lib3mf,
  libzip,
  spacenavSupport ? stdenv.hostPlatform.isLinux,
  libspnav,
  wayland,
  wayland-protocols,
  wrapGAppsHook3,
  cairo,
  openscad,
  runCommand,
  python3,
  ghostscript,
  tbb,
  qt6,
  qt6Packages,
}:

stdenv.mkDerivation rec {
  pname = "openscad";
  version = "0-unstable-2025-09-04";

  src = fetchgit {
    url = "https://github.com/openscad/openscad.git";
    rev = "76ff57a4e3d10d523b29cd2d78871adfa160ec17";
    hash = "sha256-u2Iv0mPo+F81LAuh2bGo9psH17E2Fhqu1frXuoZoeC8=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    bison
    flex
    pkg-config
    gettext
    cmake
    wrapGAppsHook3
    python3
    ghostscript
    qt6.qttools
    qt6.wrapQtAppsHook
    qt6.qt5compat
    qt6.qtmultimedia
    qt6.qtbase
    qt6Packages.qscintilla
  ];

  buildInputs = [
    eigen
    boost
    glew
    opencsg
    cgal
    mpfr
    gmp
    glib
    harfbuzz
    lib3mf
    libzip
    double-conversion
    freetype
    fontconfig
    cairo
    tbb
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libGLU
    libGL
    wayland
    wayland-protocols
  ]
  ++ lib.optional spacenavSupport libspnav;

  cmakeFlags = [
    "-DUSE_QT6=ON"
    "-DVERSION=${version}"
    "-DLIB3MF_INCLUDE_DIR=${lib3mf.dev}/include/lib3mf/Bindings/Cpp"
    "-DLIB3MF_LIBRARY=${lib3mf}/lib/lib3mf.so"
  ]
  ++ lib.optionals spacenavSupport [
    "-DENABLE_SPNAV=ON"
    "-DSPNAV_INCLUDE_DIR=${libspnav}/include"
    "-DSPNAV_LIBRARY=${libspnav}/lib/libspnav.so"
    "-DCMAKE_CXX_STANDARD=17"
  ];

  enableParallelBuilding = true;

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir $out/Applications
    mv $out/bin/*.app $out/Applications
    rmdir $out/bin || true

    mv --target-directory=$out/Applications/OpenSCAD.app/Contents/Resources \
      $out/share/openscad/{examples,color-schemes,locale,libraries,fonts,templates}

    rmdir $out/share/openscad
  '';

  meta = {
    description = "3D parametric model compiler";
    longDescription = ''
      OpenSCAD is a software for creating solid 3D CAD objects. It is free
      software and available for Linux/UNIX, MS Windows and macOS.

      Unlike most free software for creating 3D models (such as the famous
      application Blender) it does not focus on the artistic aspects of 3D
      modelling but instead on the CAD aspects. Thus it might be the
      application you are looking for when you are planning to create 3D models of
      machine parts but pretty sure is not what you are looking for when you are more
      interested in creating computer-animated movies.
    '';
    homepage = "https://openscad.org/";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [
      bjornfor
      raskin
    ];
    mainProgram = "openscad";
  };

  passthru.tests = {
    lib3mf_support =
      runCommand "${pname}-lib3mf-support-test"
        {
          nativeBuildInputs = [ openscad ];
        }
        ''
          echo "cube([1, 1, 1]);" | openscad -o cube.3mf -
          echo "import(\"cube.3mf\");" | openscad -o cube-import.3mf -
          mv cube-import.3mf $out
        '';
  };
}
