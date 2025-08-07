{ pkgs }:

pkgs.nixxrun.desktopCollector {
  name = "desktop-entries";
  buildInputs = with pkgs; [ 
    blender 
    gimp 
    freecad
    inkscape
    # oneshot
    drawing
    via
    jetbrains.idea-ultimate
  ];
}
