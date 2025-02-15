{
  python3Packages,
  fetchFromGitHub,
  lib,
}:

python3Packages.buildPythonApplication {
  pname = "pandoc-mustache";
  version = "0.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "michaelstepner";
    repo = "pandoc-mustache";
    rev = "5d63040554d1f4c2babeed29caec8fcb334ec946";
    hash = "sha256-PQEq2Tg4VibdejQqNWjNsWfL5D0RbozJHAyGmNxGrc0=";
  };

  build-system = with python3Packages; [
    setuptools
    pyparsing
  ];

  dependencies = with python3Packages; [
    panflute
    pystache
    pyyaml
    future
  ];

  meta = {
    description = "Pandoc Mustache Filter";
    homepage = "https://github.com/michaelstepner/pandoc-mustache";
    maintainers = with lib.maintainers; [ averdow ];
    license = with lib.licenses; [
      cc-by-10
    ];
  };
}
