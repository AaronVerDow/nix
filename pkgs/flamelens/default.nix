{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "flamelens";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "YS-L";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-cvsBeV9pdgr8V+82Fw/XZS1Ljq/7ff4JYMHnNxqNvOM=";
  };

  cargoHash = "sha256-Z59Ba2tvriHNfQCGBX0aZ8xKQM+tVd7YJPv+K/SF4CM=";

  meta = {
    description = "Interactive flamegraph viewer in the terminal";
    homepage = "https://github.com/YS-L/flamelens";
    changelog = "https://github.com/YS-L/flamelens/releases/tag/${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.averdow ];
  };
}
