{
  lua,
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "awesome-wm-widgets";
  version = "0-unstable-2025-01-08";

  src = fetchFromGitHub {
    owner = "streetturtle";
    repo = "awesome-wm-widgets";
    rev = "1dfa75cee48f991f7ec2a034ab27fc3a6bc8ce73";
    hash = "sha256-m5WzRgZjHjnCVjh1GKEzqE4NP0/nuGsNpH4KvOggDPY=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/lua/${lua.luaversion}/awesome-wm-widgets
    cp -r $src/* $out/lib/lua/${lua.luaversion}/awesome-wm-widgets

    runHook postInstall
  '';
  
  meta = with lib; {
    description = "Widgets for Awesome window manager";
    homepage = "https://github.com/streetturtle/awesome-wm-widgets";
    license = licenses.mit;
    maintainers = with maintainers; [ averdow ];
  };
}
