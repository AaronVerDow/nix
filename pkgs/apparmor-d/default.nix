{
  buildGoModule,
  fetchFromGitHub,
  lib,
  unstableGitUpdater,
}:
buildGoModule {
  pname = "apparmor-d";
  version = "unstable-2025-05-04";

  src = fetchFromGitHub {
    rev = "6d8eda6b8735626d5c2d25a810fb7600a4e3d60e";
    owner = "roddhjav";
    repo = "apparmor.d";
    hash = "sha256-y0qdiijSZligYPpt5qbK36KAt+q6mHN03lOqq6HPSRA=";
  };

  vendorHash = null;

  doCheck = false;
  dontCheckForBrokenSymlinks = true;

  patches = [
    ./prebuild.patch
  ];

  subPackages = [
    "cmd/prebuild"
    "cmd/aa-log"
  ];

  passthru.updateScript = unstableGitUpdater { };

  postInstall = ''
    mkdir -p $out/etc

    DISTRIBUTION=nixos $out/bin/prebuild --abi 4 # fixme: replace with nixos support once available

    mv .build/apparmor.d $out/etc
    rm $out/bin/prebuild
  '';

  meta = {
    description = "Full set of AppArmor profiles (~ 1500 profiles) ";
    homepage = "https://github.com/roddhjav/apparmor.d";
    license = lib.licenses.gpl2Only;
    mainProgram = "aa-log";
    maintainers = with lib.maintainers; [ grimmauld ];
    platforms = lib.platforms.linux;
  };
}
