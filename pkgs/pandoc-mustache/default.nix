{
  buildPythonApplication,
  fetchPypi,
  lib,
  python3Packages,
}:

buildPythonApplication rec {
  pname = "pandoc-mustache";
  version = "0.1.0";
  # format = "setuptools";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-xGjRwhZ2zx+YJARaB4/l1OhFauy/LMosIjMQqoGnxrM=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [ 
    pyparsing
    panflute
    pystache
    pyyaml
    future
  ];

  # nativeCheckInputs = [ python3Packages.pytestCheckHook ];

  # pythonImportsCheck = [ ];

  meta = with lib; {
    description = "Pandoc Mustache Filter";
    homepage = "https://github.com/michaelstepner/pandoc-mustache";
    license = with licenses; [
      lgpl3Only # or
      bsd3
    ];
  };
}
