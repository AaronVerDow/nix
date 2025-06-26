# Satisfactory File Parser Nix Package

This is a Nix package for the `@etothepii4/satisfactory-file-parser` npm library, which provides TypeScript parsing capabilities for Satisfactory save and blueprint files.

## Usage

### Building the package

```bash
nix build .#satisfactory-file-parser
```

### Using in a NixOS configuration

```nix
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    satisfactory-file-parser
  ];
}
```

### Using in a development environment

```nix
{ pkgs, ... }: {
  devShells.default = pkgs.mkShell {
    packages = with pkgs; [
      satisfactory-file-parser
      nodejs
    ];
  };
}
```

## Package Information

- **Source**: https://github.com/etothepii4/satisfactory-file-parser
- **License**: MIT
- **Description**: TypeScript parser for Satisfactory save and blueprint files

## Notes

- The package uses `buildNpmPackage` for proper Node.js dependency handling
- The built package is installed in the standard Node.js module structure
- You'll need to update the `hash` and `npmDepsHash` values when the source changes 