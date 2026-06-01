{ pkgs, setuptools ? import <nixpkgs> {} }:

pkgs.python3.pkgs.buildPythonPackage rec {
  pname = "pdfCropMargins"; # Replace with your package name
  version = "2.2.1"; # Replace with your target version

  src = pkgs.python3.pkgs.fetchPypi {
    inherit pname version;
    # Replace this hash with the correct one or use lib.fakeHash
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; 
  };

  # Build-time dependencies (e.g. setuptools, hatchling, flit)
  nativeBuildInputs = with pkgs.python3.pkgs; [
    setuptools
    wheel
  ];

  # Runtime dependencies (other python modules)
  # propagatedBuildInputs = with pkgs.python3.pkgs; [
    # idna
    # certifi
  # ];

  # Disable tests if they require internet access or fail due to paths
  doCheck = false; 

  meta = {
    description = "Python HTTP for Humans";
    homepage = "https://readthedocs.io";
  };
}
