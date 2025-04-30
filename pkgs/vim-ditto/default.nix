{ lib, vimUtils, fetchFromGitHub }:

vimUtils.buildVimPlugin {
  name = "vim-ditto";
  src = fetchFromGitHub {
    owner = "dbmrq";
    repo = "vim-ditto";
    rev = "c21f0e2f651e0ae87788390dca2fb97af7fb8fcf";
    hash = "sha256-ZCcX4fj7zVmjJmvFSgESir723NWq4ae1E7XAJ4ElRiI=";
  };
  meta = with lib; {
    description = "Highlight duplicate words in vim";
    license = licenses.mit;
  };
}
