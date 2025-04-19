{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }: 
    let
      system = "x86_64-linux"; # Change if needed
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system} = {
        openscad = pkgs.callPackage ./default.nix {};
      };

      defaultPackage.${system} = self.packages.${system}.openscad;
    };
}
