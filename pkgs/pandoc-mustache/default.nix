{
  buildPythonApplication,
  fetchPypi,
  lib,
  python3Packages,
}:

buildPythonApplication rec {
  pname = "pandoc-mustache";
  version = "0.1.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-xGjRwhZ2zx+YJARaB4/l1OhFauy/LMosIjMQqoGnxrM=";
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
