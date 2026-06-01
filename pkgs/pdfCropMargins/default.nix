{ pkgs }:

pkgs.python3.pkgs.buildPythonPackage rec {
  pname = "pdfCropMargins";
  version = "2.2.1";

  src = pkgs.fetchFromGitHub {
    owner = "abarker";
    repo = "pdfCropMargins";
    rev = "refs/tags/release_${version}";
    hash = "sha256-MPid0TcYg8TyFrTmDQD56j4GZpX8OmIzKpRidU/l5Go=";
  };

  # Use pyproject.toml build
  format = "pyproject";

  # Build-time dependencies
  nativeBuildInputs = with pkgs.python3.pkgs; [
    setuptools
    wheel
  ];

  # Runtime dependencies
  propagatedBuildInputs = with pkgs.python3.pkgs; [
    # PyMuPDF  # Required for pdfCropMargins v2.x
    pymupdf
    pillow
  ];

  doCheck = false;

  meta = {
    description = "Crop white margins from PDF files automatically";
    homepage = "https://github.com/abarker/pdfCropMargins";
    license = pkgs.lib.licenses.gpl3Only;
    maintainers = [];
  };
}
