{ lib, vimUtils, fetchFromGitHub }:

vimUtils.buildVimPlugin {
  name = "openscad-preview";
  src = fetchFromGitHub {
    owner = "AaronVerDow";
    repo = "openscad-preview.nvim";
    rev = "0d6b6e45830e45c4e5f9831204ec12f57a250cbb";
    hash = "sha256-ZCcy4fj7zVmjJmvFSgESir723NWq4ae1E7XAJ4ElRiI=";
  };
  meta = with lib; {
    description = "Automatic OpenSCAD preview with Vim";
    license = licenses.mit;
  };
}
