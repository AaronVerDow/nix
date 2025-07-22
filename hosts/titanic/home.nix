{ ... }:

{
  imports = [ ../../common/home.nix ];

  home.sessionVariables = {
    OLLAMA_API_BASE = "http://127.0.0.1:11434";
  };
}
