{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    shellcheck
    typescript
    nodejs
    jdk
    jdt-language-server
    nixd
    python3
    python3Packages.black
    graphviz # plantuml
    ccls
  ];
  programs.neovim = {
    enable = true;
    plugins =
      with pkgs.vimPlugins;
      [
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
        goyo-vim # minimal interface
        limelight-vim # highlight current editing block
        vim-wordy

        # shell
        coc-sh
        nvim-treesitter-parsers.bash
        vim-shellcheck

        # typescript
        typescript-tools-nvim
        plenary-nvim # required for typescript-tools

        # python
        coc-pyright
        nvim-treesitter-parsers.python

        # lazy java setup
        coc-java
        nvim-treesitter-parsers.java

        # plantuml
        plantuml-syntax
        plantuml-previewer-vim
        open-browser-vim # required for plantuml previewer

        # C
        vim-ccls
        nvim-treesitter-parsers.cpp

      ]
      ++ [
        pkgs.openscad-preview
        pkgs.vim-ditto
      ];
    extraLuaConfig =
      let
        file = builtins.readFile ./init.lua;
      in
      ''${file}'';
    extraConfig =
      let
        file = builtins.readFile ./init.vim;
      in
      ''${file}'';
  };

  home.file.".config/nvim/coc-settings.json" = {
    source = ./coc-settings.json;
  };
}
