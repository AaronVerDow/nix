{
  python3Packages,
  fetchFromGitHub,
  copyDesktopItems,
  makeDesktopItem,
  gobject-introspection,
  v4l-utils,
  ffmpeg,
  wrapGAppsHook3,
  lib,
}:

python3Packages.buildPythonApplication {
  pname = "camset";
  version = "0-unstable-2023-05-31";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "AaronVerDow";
    repo = "camset";
    rev = "5f0d0d671d0bdfd5027d91adbfd93c463d831609";
    hash = "sha256-mgZuPvKiMtBcswFdTDOS2sLlEusQh7RJxT9m1/YzhFc=";
  };

  build-system = with python3Packages; [ setuptools ];

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
    copyDesktopItems
  ];

  dependencies =
    with python3Packages;
    [
      pygobject3
      opencv-python
    ]
    ++ [ ffmpeg ];

  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=(
      "''${gappsWrapperArgs[@]}"
      --prefix PATH : ${lib.makeBinPath [ v4l-utils ]}
    )
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "camset";
      exec = "camset";
      icon = "camera";
      comment = "Adjust webcam settings";
      desktopName = "Camset";
      categories = [
        "Utility"
        "Video"
      ];
      type = "Application";
    })
  ];

  meta = {
    description = "GUI for Video4Linux adjustments of webcams";
    homepage = "https://github.com/azeam/camset";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ averdow ];
  };
}
