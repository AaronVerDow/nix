{ lib, vimUtils, fetchFromGitHub }:

vimUtils.buildVimPlugin {
  name = "openscad-preview";
  src = fetchFromGitHub {
    owner = "AaronVerDow";
    repo = "openscad-preview.nvim";
    rev = "145d52e7252ec116c76dd51744f4c0c960aef218";
    hash = "sha256-ZCcy4fj7zVmjJmvFSgESir723NWq4ae1E7XAJ4ElRiI=";
  };
  meta = with lib; {
    description = "Automatic OpenSCAD preview with Vim";
    license = licenses.mit;
  };
}
