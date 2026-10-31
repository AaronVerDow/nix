#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

hosts=$(nix eval --raw ".#nixosConfigurations" \
    --apply 'x: builtins.concatStringsSep "\n" (builtins.attrNames x)')

failed=()
built=()

for host in $hosts; do
    echo "=== Building $host ==="
    if nix build ".?submodules=1#nixosConfigurations.${host}.config.system.build.toplevel"; then
        built+=("$host")
    else
        echo "!!! Failed to build $host"
        failed+=("$host")
    fi
done

echo
echo "Built: ${built[*]:-none}"
if [ ${#failed[@]} -gt 0 ]; then
    echo "Failed: ${failed[*]}"
    exit 1
fi
echo "All hosts built successfully."
