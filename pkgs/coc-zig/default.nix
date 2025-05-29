{ lib, vimUtils, fetchFromGitHub }:

vimUtils.buildVimPlugin {
  name = "coc-zig";
  src = fetchFromGitHub {
    owner = "UltiRequiem";
    repo = "coc-zig";
    rev = "8af945492af8caf561732c0e765299f13f7a0842";
    hash = "sha256-Jh8brdUIhbaQbrIbkVaNZ11Ymb48vJpq7T5B5eM5CmI=";
  };
  meta = with lib; {
    description = "ZLS for coc.nvim - Zig Language Server support for coc.nvim";
    homepage = "https://github.com/UltiRequiem/coc-zig";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
} 