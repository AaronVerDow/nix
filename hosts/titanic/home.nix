{ lib, pkgs, ... }:

{
  imports = [ 
    ../../common/home.nix 
    ../../common/x/home.nix 
  ];

  home.sessionVariables = {
    OPENAI_API_BASE = "http://127.0.0.1:11433/v1";
    ANTHROPIC_BASE_URL = "http://127.0.0.1:11433";
  };

  home.packages = lib.mkMerge [(with pkgs; [
    unstable.stable-diffusion-cpp-cuda
    ]) 
  ];
}
