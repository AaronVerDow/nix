{
  pkgs ? import <nixpkgs> { },
}:

let
  launcher =
    {
      name ? "nixxrun-launcher",
      nativeBuildInputs ? [ ],
      file_prefix ? "nxr_",
      name_prefix ? "Nix Run",
      ...
    }@args:
    pkgs.stdenv.mkDerivation (
      {
        name = if args ? name then args.name else name;
        phases = [ "installPhase" ];

        nativeBuildInputs = nativeBuildInputs;
        buildInputs = [ pkgs.nixxrun ];

        installPhase = ''
          tmp=$( mktemp -d )
          for pkg in ${toString nativeBuildInputs}; do
            # there has to be a better way
            package_name=$( basename $pkg | cut -d- -f2- | sed 's/-[0-9].*//' )
            mkdir -p $tmp/share
            if [ -d "$pkg/share/icons" ]; then
              ${pkgs.rsync}/bin/rsync -rL --chmod=Du+w $pkg/share/icons $tmp/share
            fi
            if [ -d "$pkg/share/applications" ]; then
              ${pkgs.rsync}/bin/rsync -rL --chmod=Du+w $pkg/share/applications $tmp/share
            fi

            # add file_prefix to files to avoid collisions
            find $tmp/share -type f | while read file; do
              mv "$file" "$( dirname $file )/${file_prefix}$( basename $file )"
            done

            # modify desktop entries
            find $tmp/share/applications -type f | while read file; do
                sed -i 's/^Name=/Name=${name_prefix} /' "$file"
                sed -i "s/^Exec=.*/Exec=nixxrun $package_name/" "$file"
                sed -i "s/^Icon=/Icon=${file_prefix}/" "$file"
                sed -i '/TryExec/d' "$file"
            done

            mkdir -p $out/share
            ${pkgs.rsync}/bin/rsync -r $tmp/share/* $out/share
            rm -r $tmp/share/*
          done
        '';
      }
      // (removeAttrs args [
        "nativeBuildInputs"
        "file_prefix"
        "name_prefix"
      ])
    );
in

pkgs.stdenv.mkDerivation {
  pname = "nixxrun";
  version = "1.0.0";

  src = ./.;

  nativeBuildInputs = with pkgs; [ makeWrapper ];
  buildInputs = with pkgs; [
    bash
    kitty
  ];

  dontBuild = true;

  installPhase = ''
    # Install binary
    mkdir -p $out/bin
    cp $src/nixxrun.sh $out/bin/nixxrun
    chmod +x $out/bin/nixxrun
    wrapProgram $out/bin/nixxrun --prefix PATH : ${
      pkgs.lib.makeBinPath [
        pkgs.bash
        pkgs.kitty
        pkgs.nix
      ]
    }

  '';

  passthru = {
    launcher = args: launcher args;
  };
}
