#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ]; then
    echo "Usage: $0 <nix-package-name>"
    exit 1
fi

PACKAGE_NAME="$1"

TEMP_OUTPUT=$(mktemp)

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

trap cleanup_exit EXIT INT TERM

(
    echo "Loading $PACKAGE_NAME..." | tee "$TEMP_OUTPUT"
    nix-shell -p "$PACKAGE_NAME" --run "echo 'Package loaded successfully'; exec $PACKAGE_NAME" 2>&1 | tee -a "$TEMP_OUTPUT"
) &

BG_PID=$!

# Show progress in a terminal window
if command -v kitty >/dev/null 2>&1; then
    kitty -e sh -c "tail -f $TEMP_OUTPUT" &
    TERMINAL_PID=$!
elif command -v xterm >/dev/null 2>&1; then
    xterm -e sh -c "tail -f $TEMP_OUTPUT" &
    TERMINAL_PID=$!
elif command -v gnome-terminal >/dev/null 2>&1; then
    gnome-terminal -- bash -c "tail -f $TEMP_OUTPUT" &
    TERMINAL_PID=$!
elif command -v konsole >/dev/null 2>&1; then
    konsole --hold -e sh -c "tail -f $TEMP_OUTPUT" &
    TERMINAL_PID=$!
else
    # Fallback to showing output in terminal
    tail -f "$TEMP_OUTPUT"
fi

# Wait for the background process to complete
wait $BG_PID

cleanup
trap - EXIT INT TERM

# Execute the package
nix-shell -p "$PACKAGE_NAME" --run "$PACKAGE_NAME" &
