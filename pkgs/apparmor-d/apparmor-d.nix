{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "apparmor-d";
  version = "unstable-2024-10-12";

  src = fetchFromGitHub {
    rev = "116272b8ada281178150f1c9a564aac1967121f6";
    owner = "roddhjav";
    repo = "apparmor.d";
    hash = "sha256-Yx9UJdmBqjMSPVwFyvidQXfQ4pdEKaDMfvi7gF6GSVc=";
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
