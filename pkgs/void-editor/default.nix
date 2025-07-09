{
  lib,
  stdenv,
  callPackage,
  vscode-generic,
  fetchurl,
  nixosTests,
  commandLineArgs ? "",
  useVSCodeRipgrep ? stdenv.isDarwin,
}:

let
  pname = "void-editor";
  version = "1.99.30044";

  inherit (stdenv.hostPlatform) system;

  throwSystem = throw "Unsupported system: ${system}";

  archive_fmt = if stdenv.isDarwin then "zip" else "tar.gz";

  mkFetchurl =
    { plat, hash }:
    fetchurl {
      url = "https://github.com/voideditor/binaries/releases/download/${version}/Void-${plat}-${version}.${archive_fmt}";
      inherit hash;
    };

  sources = {
    x86_64-linux = mkFetchurl {
      plat = "linux-x64";
      hash = "sha256-e+uXS1Jxa+dzl+Qg4MEDYl7XFFNlOT7O96oWB2bAagQ=";
    };
  };

  sourceRoot = lib.optionalString (!stdenv.isDarwin) ".";
in
(callPackage vscode-generic rec {
  inherit
    sourceRoot
    commandLineArgs
    useVSCodeRipgrep
    pname
    version
    ;

  # Please backport all compatible updates to the stable release.
  # This is important for the extension ecosystem.
  executableName = "void";
  longName = "Void Editor";
  shortName = "void";

  src = sources.${system} or throwSystem;

  tests = nixosTests.vscodium;

  updateScript = ./update-void-editor.sh;

  meta = with lib; {
    description = ''
      Void is the open-source Cursor alternative.
    '';
    longDescription = ''
      Open source source code editor fork of VSCode adding integrated
      agentic code assitant features, akin to Cursor (i.e., code-cursor).
    '';
    homepage = "https://voideditor.com";
    downloadPage = "https://github.com/voideditor/binaries/releases";
    license = licenses.apsl20;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ jskrzypek ];
    mainProgram = "void";
    platforms = builtins.attrNames sources;
  };
})
// {
  inherit sources;
}
