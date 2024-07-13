{ pkgs ? import <nixpkgs> {} }:

pkgs.writeShellApplication {
  name = "my-shell-app";
  runtimeInputs = with pkgs; [ bash ];
  text = ''
    #!/usr/bin/env bash
    echo "Hello, world!"
  '';
}
