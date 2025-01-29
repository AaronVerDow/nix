{
  description = "A flake for fancy-cat";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zig2nix.url = "github:Cloudef/zig2nix";
  };

  outputs = { self, nixpkgs, zig2nix }: 
    let
      system = "x86_64-linux"; # Change if needed
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system} = {
        fancy-cat = pkgs.callPackage ./default.nix {
          zig2nix = zig2nix.packages.${system}.default;
        };
      };

      defaultPackage.${system} = self.packages.${system}.fancy-cat;
    };
}
