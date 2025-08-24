# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  xrotate = pkgs.callPackage ./xrotate { };
  grammar = pkgs.callPackage ./grammar { };
  openscad-post-processor = pkgs.callPackage ./openscad-post-processor { };
  openscad-preview = pkgs.callPackage ./openscad-preview.nvim { };
  vim-ditto = pkgs.callPackage ./vim-ditto { };
  coc-zig = pkgs.callPackage ./coc-zig { };
  restream-desktop = pkgs.callPackage ./restream-desktop { };
  my_numworks = pkgs.callPackage ./my_numworks { };
  my_fancy-cat = pkgs.callPackage ./my_fancy-cat { };
  my_camset = pkgs.callPackage ./my_camset { };
  satisfactory-file-parser = pkgs.callPackage ./satisfactory-file-parser { };
  my_freecad = pkgs.callPackage ./freecad { };
  qman = pkgs.callPackage ./qman { };
  neovim-thumbnailer = pkgs.callPackage ./neovim-thumbnailer { };

  awesomeWithWidgets = pkgs.writeShellScriptBin "awesome" ''
    export LUA_PATH="${pkgs.luaPackages.awesome-wm-widgets}/lib/lua/${pkgs.lua.luaversion}/?.lua;''${LUA_PATH:-;;}"
    export LUA_CPATH="${pkgs.luaPackages.awesome-wm-widgets}/lib/lua/${pkgs.lua.luaversion}/?.so;''${LUA_CPATH:-;;}"
    echo "$LUA_PATH" > /tmp/awesome.log
    echo "$LUA_CPATH" >> /tmp/awesome.log
    exec ${pkgs.awesome}/bin/awesome "$@" &>> /tmp/awesome.log
  '';
  nix-run-desktop = pkgs.callPackage ./nix-run-desktop { };
}
