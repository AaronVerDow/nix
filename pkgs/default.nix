# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  # example = pkgs.callPackage ./example { };
  my_numworks = pkgs.callPackage ./my_numworks { };
  xrotate = pkgs.callPackage ./xrotate { };
  my_fancy-cat = pkgs.callPackage ./my_fancy-cat { };
}
