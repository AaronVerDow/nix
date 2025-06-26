#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Get the path to the installed module relative to this script
const modulePath = path.join(__dirname, '../lib/node_modules/@etothepii4/satisfactory-file-parser');
const { Parser } = require(modulePath);

function printUsage() {
  console.log(`
Usage: sbp-to-json <sbp-file> [output-file]

Converts a Satisfactory blueprint (.sbp) file to JSON format.

Arguments:
  sbp-file     Path to the .sbp blueprint file
  output-file  Optional output JSON file path (default: <sbp-file>.json)

Examples:
  sbp-to-json MyBlueprint.sbp
  sbp-to-json MyBlueprint.sbp output.json
  sbp-to-json /path/to/blueprint.sbp
`);
}

function main() {
  const args = process.argv.slice(2);
  
  if (args.length === 0 || args.includes('--help') || args.includes('-h')) {
    printUsage();
    process.exit(0);
  }

  const sbpFilePath = args[0];
  let outputPath = args[1];

  // Validate input file
  if (!fs.existsSync(sbpFilePath)) {
    console.error(`Error: File '${sbpFilePath}' does not exist.`);
    process.exit(1);
  }

  if (!sbpFilePath.endsWith('.sbp')) {
    console.error(`Error: File '${sbpFilePath}' does not have a .sbp extension.`);
    process.exit(1);
  }

  // Determine config file path
  const configFilePath = sbpFilePath.replace(/\.sbp$/, '.sbpcfg');
  
  if (!fs.existsSync(configFilePath)) {
    console.error(`Error: Config file '${configFilePath}' not found.`);
    console.error('Blueprint files require both .sbp and .sbpcfg files.');
    process.exit(1);
  }

  // Determine output path
  if (!outputPath) {
    outputPath = sbpFilePath.replace(/\.sbp$/, '.json');
  }

  try {
    console.log(`Reading blueprint file: ${sbpFilePath}`);
    console.log(`Reading config file: ${configFilePath}`);
    
    // Read the files
    const mainFile = new Uint8Array(fs.readFileSync(sbpFilePath)).buffer;
    const configFile = new Uint8Array(fs.readFileSync(configFilePath)).buffer;
    
    // Get the blueprint name from the filename
    const blueprintName = path.basename(sbpFilePath, '.sbp');
    
    console.log(`Parsing blueprint: ${blueprintName}`);
    
    // Parse the blueprint
    const blueprint = Parser.ParseBlueprintFiles(blueprintName, mainFile, configFile);
    
    // Write to JSON file
    const jsonOutput = JSON.stringify(blueprint, null, 2);
    fs.writeFileSync(outputPath, jsonOutput);
    
    console.log(`Successfully converted to: ${outputPath}`);
    
  } catch (error) {
    console.error('Error parsing blueprint:', error.message);
    process.exit(1);
  }
}

if (require.main === module) {
  main();
} 