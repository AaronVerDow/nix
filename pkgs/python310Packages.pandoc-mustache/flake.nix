{
  description = "Pandoc Mustache - Python Package";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.default = nixpkgs.lib.mkPythonApp rec {
      pname = "pandoc-mustache";
      version = "latest";

      src = nixpkgs.lib.cleanSource ./pandoc-mustache;

      nativeBuildInputs = [ nixpkgs.python310Packages.setuptools ];
      
      meta = with nixpkgs.lib; {
        description = "Pandoc filter that allows the use of Mustache templates.";
        license = licenses.mit;
        maintainers = [ maintainers.yourname ];
      };
    };
  };
}
