{ lib, vimUtils }:

vimUtils.buildVimPlugin {
  name = "openscad-preview";
  src = ./.;
  meta = with lib; {
    description = "Automatic OpenSCAD preview with Vim";
    license = licenses.mit;
  };
}
