{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pyparsing,
  pytestCheckHook,
  pythonOlder,
}:

buildPythonPackage rec {
  pname = "python-mustache";
  version = "0.1.0";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "michaelstepner";
    repo = "${pname}";
    rev = "refs/tags/v${version}";
    hash = "sha256-YMkLSx7L2srLINZa6Ec0rPoxE2SdMv6CnI4BpHgHuzM=";
  };

  propagatedBuildInputs = [ pyparsing ];

  nativeCheckInputs = [ pytestCheckHook ];

  pythonImportsCheck = [ "pandoc-mustache" ];

  meta = with lib; {
    description = "Pandoc Mustache Filter";
    homepage = "https://github.com/michaelstepner/pandoc-mustache";
    license = with licenses; [
      lgpl3Only # or
      bsd3
    ];
  };
}
