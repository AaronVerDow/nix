{ pkgs }:

pkgs.nixxrun.desktopCollector {
  name = "nixxrun-entries";
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
