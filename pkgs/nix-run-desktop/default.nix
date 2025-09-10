{
  pkgs ? import <nixpkgs> { },
}:

let
  launcher =
    {
      name ? "",
      nativeBuildInputs ? [ ],
      file_prefix ? "nixrd_",
      name_prefix ? "Nix Run",
      copy_icons ? true,
      ...
    }@args:
    pkgs.stdenv.mkDerivation (
      {
        name =
          if args ? name then
            args.name
          else if (builtins.length nativeBuildInputs > 0) then
            let
              # this needs work
              firstPkg = builtins.elemAt nativeBuildInputs 0;
              baseName = builtins.baseNameOf firstPkg;
              stringName = builtins.toString baseName;
              unsafe = builtins.unsafeDiscardStringContext stringName;
              matches = builtins.match "(.*)-(.*)-(.*)" unsafe;
              shortName = builtins.elemAt matches 1;
              version = builtins.elemAt matches 2;
            in
            "nix-run-desktop_${shortName}-${version}"
          else
            "nix-run-desktop_EMPTY";
        phases = [ "installPhase" ];

        nativeBuildInputs = nativeBuildInputs;
        buildInputs = [ pkgs.nix-run-desktop ];

        installPhase = ''
          tmp=$( mktemp -d )
          mkdir -p $tmp/share
          for pkg in ${toString nativeBuildInputs}; do

            # get package name
            # there has to be a better way
            package_name=$( basename $pkg | cut -d- -f2- | sed 's/-[0-9].*//' )

            # copy all icons
            if ${if copy_icons then "true" else "false"} && [ -d "$pkg/share/icons" ]; then
              ${pkgs.rsync}/bin/rsync -rL --chmod=Du+w $pkg/share/icons $tmp/share
            fi
            
            # copy desktop files
            if [ -d "$pkg/share/applications" ]; then
              ${pkgs.rsync}/bin/rsync -rL --chmod=Du+w $pkg/share/applications $tmp/share
            fi

            # modify desktop entries
            find $tmp/share/applications -type f | while read file; do
                sed -i 's/^Name=/Name=${name_prefix} /' "$file"
                sed -i "s#^Exec=.*#Exec=${pkgs.nix-run-desktop}/bin/nix-run-desktop $package_name#" "$file"
                ${if copy_icons then "true" else "false"} && sed -i "s/^Icon=/Icon=${file_prefix}/" "$file"
                sed -i '/TryExec/d' "$file"
            done
          done

          # add file_prefix to all files to avoid collisions
          find $tmp/share -type f | while read file; do
            mv "$file" "$( dirname $file )/${file_prefix}$( basename $file )"
          done

          mkdir -p $out/share
          ${pkgs.rsync}/bin/rsync -r $tmp/share/* $out/share
          rm -r $tmp/share/*
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
  pname = "nix-run-desktop";
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
    cp $src/nix-run-desktop.sh $out/bin/nix-run-desktop
    chmod +x $out/bin/nix-run-desktop
    wrapProgram $out/bin/nix-run-desktop --prefix PATH : ${
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
