# TODO: define profile and copy mozilla dotfiles
{ config, pkgs, ... }:
with pkgs;
let
    wordCountContent = builtins.readFile ./wcgraph.sh;
    bookdownContent = builtins.readFile ./bookdown.sh;
    R-with-my-packages = rWrapper.override{ packages = with rPackages; [ 
        bookdown
        stringr
        tidyverse
        plantuml
        plantuml-c4
        plantuml-server
    ]; };
in
{
    home.packages = with pkgs; [
        # mlterm # variable width terminal
        R-with-my-packages
        pandoc
        texliveFull
        # pandoc-mustache # broken due to future and python 3.13
        languagetool
        grammar
        plantuml
        # rWrapper.override{packages = [ rPackages.bookdown ];}

        (writeShellApplication {
            name = "wcgraph";
            runtimeInputs = with pkgs; [ 
                python312Packages.termgraph 
                yq
            ];
            text = wordCountContent;
        })

        (writeShellApplication {
            name = "bookdown";
            text = bookdownContent;
        })
        
    ];
}
