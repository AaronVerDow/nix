{ pkgs, lib, ... }:

{
  imports = [ ../../common/home.nix ];

  # Keep this appliance's closure small; common/home.nix pulls in texliveFull
  # (~6 GB) and other desktop tooling that this host doesn't need.
  home.packages = lib.mkForce (with pkgs; [
    git
    ripgrep
    gh
  ]);

  # Use a minimal Neovim instead of the full language-tooling setup.
  my.nvim.enable = false;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withPython3 = false;
    withRuby = false;
    initLua = ''
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.termguicolors = true
      vim.opt.undofile = true
    '';
  };
}
