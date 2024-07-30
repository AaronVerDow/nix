{
  description = "Dump dconf to nix files";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.dconf-editor
            pkgs.dconf2nix
            pkgs.crudini
            pkgs.glow
          ];
          shellHook = ''
            glow README.md
          '';
        };
      });
}
