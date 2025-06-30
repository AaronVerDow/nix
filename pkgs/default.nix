# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  xrotate = pkgs.callPackage ./xrotate { };
  grammar = pkgs.callPackage ./grammar { };
  openscad-post-processor = pkgs.callPackage ./openscad-post-processor { };
  openscad-preview = pkgs.callPackage ./openscad-preview.nvim { };
  vim-ditto = pkgs.callPackage ./vim-ditto { };
  coc-zig = pkgs.callPackage ./coc-zig { };
  restream-desktop = pkgs.callPackage ./restream-desktop { };
  my_numworks = pkgs.callPackage ./my_numworks { };
  my_fancy-cat = pkgs.callPackage ./my_fancy-cat { };
  my_camset = pkgs.callPackage ./my_camset { };
  satisfactory-file-parser = pkgs.callPackage ./satisfactory-file-parser { };
}
