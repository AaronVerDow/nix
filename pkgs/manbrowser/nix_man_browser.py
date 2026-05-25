#!/usr/bin/env python3
"""NixOS configuration.nix manpage browser.

Accepts words as arguments and returns options from configuration.nix that match ALL words.
Usage: nix-man-browser <word1> <word2> ...
"""

import sys
import gzip
import re


def extract_options(filepath):
    """Extract option names from the OPTIONS section of the manpage.
    
    Options appear in format: \\fB<option_name\\fR
    e.g., \\fB<imports = [ pkgs.ghostunnel.services.default ]>\\fR
    """
    options = []
    
    with gzip.open(filepath, 'rt', encoding='utf-8', errors='replace') as f:
        text = f.read()
    
    # Extract option names from \\fB<...>\\fR pattern
    option_pattern = r'\\fB<([^>]+)>\\fR'
    matches = re.findall(option_pattern, text)
    options.extend(matches)
    
    # Also try simpler pattern for bare option names
    simple_pattern = r'\\fB([^\\fR]+)\\fR'
    simple_matches = re.findall(simple_pattern, text)
    # Filter to likely option names (start with < or common prefixes)
    for match in simple_matches:
        if not any(x in match for x in ['pkgs.', 'system.', 'lib.', 'pkgs/by-name']):
            options.append(match)
    
    # Remove duplicates while preserving order
    seen = set()
    unique_options = []
    for opt in options:
        if opt not in seen:
            seen.add(opt)
            unique_options.append(opt)
    
    return unique_options


def main():
    if len(sys.argv) < 2:
        print("Usage: nix-man-browser <word1> <word2> ...")
        print("  Returns options from configuration.nix that match ALL words.")
        sys.exit(1)
    
    words = sys.argv[1:]
    manpage_path = '/nix/store/akx7fwvg0gdwx1lmfdmqnwky7hcmi9z3-nixos-configuration-reference-manpage/share/man/man5/configuration.nix.5.gz'
    
    try:
        options = extract_options(manpage_path)
    except Exception as e:
        print(f"Error reading manpage: {e}", file=sys.stderr)
        sys.exit(1)
    
    # Find options that match ALL words (case-insensitive substring match)
    matching_options = []
    for option in options:
        option_lower = option.lower()
        if all(word.lower() in option_lower for word in words):
            matching_options.append(option)
    
    # Print results
    if matching_options:
        for option in matching_options:
            print(option)
    else:
        print("No options found matching all words.", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
