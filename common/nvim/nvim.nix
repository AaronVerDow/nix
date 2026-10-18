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
    withRuby = true;
    withPython3 = true;
    plugins =
      with pkgs.vimPlugins;
      [
        # vim-sleuth # auto detect tab stop
        coc-nvim
        rainbow-delimiters-nvim
        (nvim-treesitter.withPlugins (
          p: with p; [
            c
            cpp
            bash
            java
            nix
            python
            zig
          ]
        ))
        gitsigns-nvim
        lualine-nvim
        vim-humanoid-colorscheme
        transparent-nvim
        cinnamon-nvim # smooth scroll

        # prose
        goyo-vim # minimal interface
        limelight-vim # highlight current editing block
        vim-wordy

        # shell
        coc-sh
        vim-shellcheck

        # typescript
        typescript-tools-nvim
        plenary-nvim # required for typescript-tools

        # python
        coc-pyright

        # lazy java setup
        # coc-java

        # plantuml
        plantuml-syntax
        plantuml-previewer-vim
        open-browser-vim # required for plantuml previewer

        # C
        vim-ccls

        # Zig
        zig-vim
        # (coc is a custom package below)

        Jenkinsfile-vim-syntax
      ]
      ++ [
        pkgs.openscad-preview
        pkgs.vim-ditto
        pkgs.coc-zig
      ];
    initLua =
      let
        file = builtins.readFile ./init.lua;
      in
      "${file}";
    extraConfig =
      let
        file = builtins.readFile ./init.vim;
      in
      "${file}";
  };

  home.file.".config/nvim/coc-settings.json" = {
    text = builtins.toJSON (
      builtins.fromJSON (builtins.readFile ./coc-settings.json)
      // {
        java.jdt.ls.java.home = "${pkgs.jdk17}/lib/openjdk";
      }
    );
  };
}
