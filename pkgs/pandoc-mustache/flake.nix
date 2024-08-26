{
  description = "Pandoc Mustache - Python Package";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    packages = let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
      };
    in {
      default = pkgs.python310Packages.buildPythonPackage rec {
        pname = "pandoc-mustache";
        version = "latest";

        # Fetch from GitHub
        src = pkgs.fetchFromGitHub {
          owner = "michaelstepner";
          repo = "pandoc-mustache";
          rev = "master";
          sha256 = "asdf";
        };

        nativeBuildInputs = [ pkgs.python310Packages.setuptools ];

        meta = with pkgs.lib; {
          description = "Pandoc filter that allows the use of Mustache templates.";
          license = licenses.mit;
          maintainers = [ "Aaron VerDow" ];  # Replace with your handle
        };
      };
    };
  };
}
