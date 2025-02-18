{
  stdenv,
  lib,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "awesome-wm-widgets";
  version = "0-unstable-2024-02-15";

  src = fetchFromGitHub {
    owner = "streetturtle";
    repo = "awesome-wm-widgets";
    commit = "2a27e625056c50b40b1519eed623da253d36cc27";
    hash = "sha256-w9ddcULE1MrGnYcXA0qOg1elQv/eBhcXqhMSjWT3Bkk=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/awesome/lib/awesome-wm-widgets
    cp -r $src/* $out/share/awesome/lib/awesome-wm-widgets

    runHook postInstall
  '';
  
  meta = with lib; {
    description = "Widgets for Awesome window manager";
    homepage = "https://github.com/streetturtle/awesome-wm-widgets";
    license = licenses.mit;
    maintainers = with maintainers; [ averdow ];
  };
}
