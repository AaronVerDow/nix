{
  pkgs ? import <nixpkgs> { },
}:

let
  myNeovim = pkgs.neovim.override {
    configure = {
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [
          vim-sleuth # auto detect tab stop
          coc-nvim
          rainbow-delimiters-nvim
          nvim-treesitter
          gitsigns-nvim
          lualine-nvim
          vim-humanoid-colorscheme
          transparent-nvim
          cinnamon-nvim # smooth scroll

          # nix
          nvim-treesitter-parsers.nix

          # prose
          goyo-vim
          limelight-vim
          vim-wordy

          # shell
          coc-sh
          nvim-treesitter-parsers.bash
          vim-shellcheck

          # typescript
          typescript-tools-nvim
          plenary-nvim

          # python
          coc-pyright
          nvim-treesitter-parsers.python

          # java
          coc-java
          nvim-treesitter-parsers.java

          # plantuml
          plantuml-syntax
          plantuml-previewer-vim
          open-browser-vim

          # C / C++
          vim-ccls
          nvim-treesitter-parsers.cpp

          # Zig
          zig-vim
          nvim-treesitter-parsers.zig

          # extra vim plugins packaged outside vimPlugins
          pkgs.vim-ditto
          pkgs.coc-zig
        ];
        opt = [ ];
      };
    };
  };
in
pkgs.stdenv.mkDerivation {
  pname = "neovim-thumbnailer";
  version = "1.0.0";

  src = ./.;

  nativeBuildInputs = with pkgs; [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/thumbnailers
    cp ./neovim.thumbnailer $out/share/thumbnailers

    outfile=$out/bin/neovim-thumbnailer
    cp $src/neovim-thumbnailer.sh $outfile
    chmod +x $outfile

    wrapProgram $outfile --prefix PATH : ${
      pkgs.lib.makeBinPath [
        pkgs.bash
        pkgs.xterm
        myNeovim
        pkgs.xorg.xwd
        pkgs.xorg.xvfb
        pkgs.xorg.xwininfo
        pkgs.imagemagick
        pkgs.openscad-preview # not a vim plugin, just a binary dep
      ]
    }
  '';
}

