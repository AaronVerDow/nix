# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  xrotate = pkgs.callPackage ./xrotate { };
  awesome-wm-widgets = pkgs.callPackage ./awesome-wm-widgets { };
  grammar = pkgs.callPackage ./grammar { };
  openscad-post-processor = pkgs.callPackage ./openscad-post-processor { };
  openscad-preview = pkgs.callPackage ./openscad-preview.nvim { };
  vim-ditto = pkgs.callPackage ./vim-ditto { };
  restream-desktop = pkgs.callPackage ./restream-desktop { };
  my_numworks = pkgs.callPackage ./my_numworks { };
  apparmor-d = pkgs.callPackage ./apparmor-d { };
}
