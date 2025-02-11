{ python3Packages, fetchFromGitHub, gobject-introspection, v4l-utils
, wrapGAppsHook3, lib }:

python3Packages.buildPythonApplication rec {
  name = "camset";
  version = "0-unstable-2023-05-20";
  pyproject = true;
  dontWrapGApps = true;

  src = fetchFromGitHub {
    owner = "azeam";
    repo = "camset";
    rev = "b813ba9b1d29f2d46fad268df67bf3615a324f3e";
    hash = "sha256-vTF3MJQi9fZZDlbEj5800H22GGWOte3+KZCpSnsSTaQ=";
  };

  build-system = with python3Packages; [ setuptools ];

  nativeBuildInputs = [ gobject-introspection wrapGAppsHook3 ];

  dependencies = with python3Packages; [ pygobject3 opencv-python ];

  propagatedBuildInputs = [ v4l-utils ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = {
    description = "GUI for Video4Linux adjustments of webcams";
    homepage = "https://github.com/azeam/camset";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ AaronVerDow ];
  };
}
