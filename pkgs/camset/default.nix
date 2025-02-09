{
  python312Packages,
  fetchFromGitHub,
  cairo,
  glib,
  gobject-introspection,
  libGL,
  stdenv,
  v4l-utils,
  gtk3,
  wrapGAppsHook3
}:

python312Packages.buildPythonPackage rec {
  name = "camset";
  src = fetchFromGitHub {
    owner = "azeam";
    repo = "camset";
    rev = "b813ba9b1d29f2d46fad268df67bf3615a324f3e";
    hash = "sha256-vTF3MJQi9fZZDlbEj5800H22GGWOte3+KZCpSnsSTaQ=";
  };

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];

  propagatedBuildInputs = [ 
    python312Packages.pytest 
    python312Packages.pygobject3
    python312Packages.opencv4
    # python312Packages.numpy 
    # pkgs.libsndfile 
    cairo
    glib
    # gobject-introspection
    libGL
    stdenv.cc.cc.lib
    v4l-utils
    gtk3
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';
}
