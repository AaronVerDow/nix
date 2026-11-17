{
  pkgs,
  lib,
  ...
}:
{
  imports = [ ../../common/home.nix ];

  # Keep this appliance's closure small; common/home.nix pulls in texliveFull
  # (~6 GB) and other desktop tooling that this host doesn't need.
  home.packages = lib.mkForce (with pkgs; [
    git
    ripgrep
    gh
    neovim
  ]);
}
