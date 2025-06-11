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
    rev = "62a41ecde70ee895df8a5200a00c545d4892d4cc";
    hash = "sha256-tOlx1u3o3jh5iwMJi3ZL5ohU16Q8ahJNaBn2azQdwmg=";
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
