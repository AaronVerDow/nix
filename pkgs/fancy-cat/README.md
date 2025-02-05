# Fancy Cat

Package [fancy-cat](https://github.com/freref/fancy-cat) for use in Nix.

This directory can be included in a Nix config as a package using `callPackage`.

The flake is used for building the package in a local shell and can be tested with `nix shell`.

`build.zig.zon.nix` is created by running `nix run github:Cloudef/zig2nix#zon2nix -- build.zig.zon` in the source repo.
