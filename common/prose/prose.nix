# TODO: define profile and copy mozilla dotfiles
{ config, pkgs, ... }:
let
    wordCountContent = builtins.readFile ./wcgraph.sh;
in
{
    home.packages = with pkgs; [
        mlterm

        (writeShellApplication {
            name = "wcgraph";
            runtimeInputs = with pkgs; [ 
                python312Packages.termgraph 
            ];
            text = wordCountContent;
        })
        
    ];
}
