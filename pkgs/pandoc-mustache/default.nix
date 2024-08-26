{ pkgs ? import <nixpkgs> { } }:

pkgs.python310Packages.buildPythonPackage rec {
  pname = "pandoc-mustache";
  version = "latest";

  src = pkgs.lib.cleanSource ./pandoc-mustache;

  nativeBuildInputs = [ pkgs.python310Packages.setuptools ];

  meta = with pkgs.lib; {
    description = "Pandoc filter that allows the use of Mustache templates.";
    license = licenses.mit;
    maintainers = with maintainers; [ yourname ];
  };
}
