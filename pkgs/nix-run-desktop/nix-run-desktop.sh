#!/usr/bin/env bash
set -euo pipefail

TERMINAL_PID=""
TEMP_OUTPUT=""

cleanup() {
    rm -f "$TEMP_OUTPUT" 2>/dev/null || true
    # Kill terminal window if it's still open
    if [[ -n "$TERMINAL_PID" ]]; then
        kill "$TERMINAL_PID" 2>/dev/null || true
    fi
}

cleanup_exit() {
    cleanup
    exit
}

build_package() {
    PACKAGE_NAME=$1
    echo "Building $PACKAGE_NAME..."
    nom build --impure nixpkgs#"$PACKAGE_NAME" 2>&1
    echo "Build complete."
}

show_progress() {
    TEMP_OUTPUT=$1
    # Show progress in a terminal window
    if command -v kitty >/dev/null 2>&1; then
        # kitty --class nix_launcher -o font_size=10 -e sh -c "tail -f $TEMP_OUTPUT" &
        kitty -e sh -c "tail -f $TEMP_OUTPUT" &
    else
        # Fallback to showing output in terminal
        tail -f "$TEMP_OUTPUT"
    fi
}

show_and_build() {
    PACKAGE_NAME=$1
    TEMP_OUTPUT=$(mktemp)

    trap cleanup_exit EXIT INT TERM

    ( build_package "$PACKAGE_NAME" | tee "$TEMP_OUTPUT" ) &

    BG_PID=$!

    show_progress "$TEMP_OUTPUT"
    TERMINAL_PID=$!

    wait $BG_PID
}

if [ $# -eq 0 ]; then
    echo "Usage: $0 <nix-package-name>"
    exit 1
fi

PACKAGE_NAME="$1"

show_and_build "$PACKAGE_NAME"

# Execute the package using nix run with nixpkgs
nix run --impure nixpkgs#"$PACKAGE_NAME" &

cleanup
trap - EXIT INT TERM
