{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nodejs,
}:

buildNpmPackage rec {
  pname = "satisfactory-file-parser";
  version = "0-unstable-2025-01-27";

  src = fetchFromGitHub {
    owner = "etothepii4";
    repo = "satisfactory-file-parser";
    rev = "8856e4f0ec0d0e8b5b6d6648a113f061e102f9ed";
    hash = "sha256-uZMc7dLJxzvMrjQoFtmVuNyCxby7SnBMdyc1UI4wl5o=";
  };

  npmDepsHash = "sha256-tc0P1Up4fX0GtG5rZ/WKvldJ9NDSEgzxVhMDOM/C2EA=";

  # Build the TypeScript package
  buildPhase = ''
    npm run build
    cp ${./sbp-to-json.js} sbp-to-json.js
  '';

  # Install the built package
  installPhase = ''
    mkdir -p $out/lib/node_modules/@etothepii4/satisfactory-file-parser
    cp -r build/* $out/lib/node_modules/@etothepii4/satisfactory-file-parser/
    cp package.json $out/lib/node_modules/@etothepii4/satisfactory-file-parser/

    # Copy runtime dependencies
    cp -r node_modules $out/lib/node_modules/@etothepii4/satisfactory-file-parser/

    # Create the proper node_modules structure
    mkdir -p $out/lib/node_modules/@etothepii4
    ln -sf $out/lib/node_modules/@etothepii4/satisfactory-file-parser $out/lib/node_modules/@etothepii4/satisfactory-file-parser

    # Install command-line script
    mkdir -p $out/bin
    cp sbp-to-json.js $out/bin/sbp-to-json
    chmod +x $out/bin/sbp-to-json
  '';

  meta = {
    description = "TypeScript parser for Satisfactory save and blueprint files";
    homepage = "https://github.com/etothepii4/satisfactory-file-parser";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
    mainProgram = "sbp-to-json";
  };
}
