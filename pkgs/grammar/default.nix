{
  python3Packages,
  languagetool,
  lib,
}:

python3Packages.buildPythonApplication rec {
  pname = "grammar";
  version = "0-unstable-2025-03-02";
  pyproject = false;

  dontUnpack = true;
  installPhase = ''
    install -Dm755 "${./grammar.py}" "$out/bin/${pname}"
  '';

  nativeBuildInputs = [
    languagetool
  ];

  dependencies = with python3Packages; [
    colored
  ];

  meta = {
    description = "Minimal command line interface for LanguageTool";
    # homepage = "https://github.com/azeam/camset";
    # license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ averdow ];
  };
}
