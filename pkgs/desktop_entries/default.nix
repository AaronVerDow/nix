{ pkgs }:

pkgs.nixxrun.desktopCollector {
  name = "desktop-entries";
  buildInputs = [ pkgs.blender pkgs.gimp ];
}
