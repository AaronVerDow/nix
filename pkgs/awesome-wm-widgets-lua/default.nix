{
  lua,
  lib,
  stdenv,
  fetchFromGitHub,
}:

# luaPackages.buildLuaPackage {
stdenv.mkDerivation {
  pname = "awesome-wm-widgets-lua";
  version = "0-unstable-2024-02-15";

  src = fetchFromGitHub {
    owner = "streetturtle";
    repo = "awesome-wm-widgets";
    rev = "cb5ef827d006bdd6fa23f68d7c5e7c9f27d8ffbd";
    hash = "sha256-ejihBFxTtuZl/KJa9BalZ8JISAjn9oWmirK37O169lw=";
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
