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

### Command-line tool

The package includes a command-line tool `sbp-to-json` for converting Satisfactory blueprint files to JSON:

```bash
# Convert a blueprint file to JSON
sbp-to-json MyBlueprint.sbp

# Convert with custom output file
sbp-to-json MyBlueprint.sbp output.json

# Get help
sbp-to-json --help
```

**Note:** Blueprint files require both a `.sbp` file and a corresponding `.sbpcfg` file in the same directory.

### Using as a Node.js library

```javascript
const { Parser } = require('@etothepii4/satisfactory-file-parser');

// Parse a blueprint file
const fs = require('fs');
const mainFile = new Uint8Array(fs.readFileSync('./MyBlueprint.sbp')).buffer;
const configFile = new Uint8Array(fs.readFileSync('./MyBlueprint.sbpcfg')).buffer;
const blueprint = Parser.ParseBlueprintFiles('MyBlueprint', mainFile, configFile);

// Parse a save file
const saveFile = new Uint8Array(fs.readFileSync('./MySave.sav')).buffer;
const save = Parser.ParseSave('MySave', saveFile);
```

## Package Information

- **Source**: https://github.com/etothepii4/satisfactory-file-parser
- **License**: MIT
- **Description**: TypeScript parser for Satisfactory save and blueprint files

## Notes

- The package uses `buildNpmPackage` for proper Node.js dependency handling
- The built package is installed in the standard Node.js module structure
- You'll need to update the `hash` and `npmDepsHash` values when the source changes 