set -euo pipefail

# cycle through these colors for highlighting as more words are passed
COLORS=(
    red
    yellow
    green
    # cyan # not visible enough
    blue
    magenta
)

COLOR_COUNT=${#COLORS[@]}

main() {
    [ -z "${1:-}" ] && return 1

    local tmp this=0 next=0

    # all fifos stored here
    tmp=$( mktemp -d )
    mkfifo "$tmp/$next"

    # strip out command number, and ignore calls to this script
    sed 's/^ *[0-9]* *//' "$HOME/.eternal" | grep -E -a -v '^(hist |eternal)'  > "$tmp/$next" &

    # loop over passed aguments
    while [ -n "${1:-}" ]; do
        next=$((this + 1))
        mkfifo "$tmp/$next"

        # rotate through color list
        index=$((this%COLOR_COUNT))

        rg -a --color=always --colors="match:fg:${COLORS[$index]}" "$1" "$tmp/$this" > "$tmp/$next" &

        this=$next
        shift
    done

    # read final fifo
    cat "$tmp/$next"

    rm -r "$tmp"
}

main "$@"
