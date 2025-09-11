{ pkgs, ... }:

{
  imports = [
    ../../common/home.nix
    ../../common/x/home.nix
  ];

  home.packages = with pkgs; [
    unstable.r2modman
    protonup-qt
    huestacean
  ];
  programs.lutris = {
    enable = true;
    winePackages = [
      pkgs.wine
    ];
  };

}
