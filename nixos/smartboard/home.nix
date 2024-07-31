{ ... }:

{
  imports = [ ../../home-manager/home.nix ];

  xresources.extraConfig = ''
    Xft.dpi: 245
  '';
}
