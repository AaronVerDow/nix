{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "apparmor-d";
  version = "unstable-2025-05-27";

  src = fetchFromGitHub {
    rev = "bf22a7786c39d3b56b87095bfd4479769b88ec1a";
    owner = "roddhjav";
    repo = "apparmor.d";
    hash = "sha256-J8h9LcZRxhTaZg7OU2m75upSoeD1i/abSCJQtX1WRsQ=";
  };

  doCheck = false;
  dontBuild = true;

  patches = [
    ./apparmor-d-paths.patch
  ];

  installPhase = ''
    mkdir -p $out/etc
    cp -r apparmor.d $out/etc
  '';
}
