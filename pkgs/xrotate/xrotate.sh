#!/usr/bin/env bash
set -euo pipefail

# Configure these to match your hardware (names taken from `xinput` output).
DEVICES='ELAN06FA:00 04F3:327E Touchpad
Wacom HID 53BC Finger'

# Auto detect primary display
XDISPLAY=$( xrandr --current | grep primary | sed -e 's/ .*//g' )

TRANSFORM='Coordinate Transformation Matrix'

current=$( xrandr --query --verbose | grep "$XDISPLAY" | cut -d ' ' -f 6 )


normal() {
    xinput set-prop "$1" "$TRANSFORM" 1 0 0 0 1 0 0 0 1
}

inverted() {
    xinput set-prop "$1" "$TRANSFORM" -1 0 1 0 -1 1 0 0 1
}

left() {
    xinput set-prop "$1" "$TRANSFORM" 0 -1 1 1 0 0 0 0 1
}

right() {
    xinput set-prop "$1" "$TRANSFORM" 0 1 0 -1 0 1 0 0 1
}

# Mirrored inputs for using the touchpad on the back of a 2 in 1 laptop

# https://en.wikipedia.org/wiki/Transformation_matrix#Affine_transformations
# reflect Y and translate X back into place:
# -1 0 1
# 0 1 0
# 0 0 1
# mutiply by rotation matricies above for final result

mirrored_left() {
    xinput set-prop "$1" "$TRANSFORM" 0 1 0 1 0 0 0 0 1
}

mirrored_right() {
    xinput set-prop "$1" "$TRANSFORM" 0 -1 1 -1 0 1 0 0 1
}

rotate() {
    rotation="$1"
    if ! echo "$rotation" | grep -Eq '(normal|inverted|left|right)'; then
        echo "Invalid rotation!"
        return 1
    fi

    xrandr --output "$XDISPLAY" --rotate "$rotation"
    # restart awesome so wibar can move
    echo 'awesome.restart()' | awesome-client
    while read -r device; do
        # hacks to use touchpad on back of pc while folded up in tablet mode
        if echo "$device" | grep -qi "touchpad"; then
            if [ "$rotation" == "left" ]; then
                mirrored_left "$device" || true
                continue
            elif [ "$rotation" == "right" ]; then
                mirrored_right "$device" || true
                continue
            fi
        fi
        $rotation "$device" || true
    done <<< "$DEVICES"
}

ccw_normal() {
    rotate left
}

ccw_left() {
    rotate inverted
}

ccw_inverted() {
    rotate right 
}

ccw_right() {
    rotate normal
}

cw_normal() {
    rotate right
}

cw_right() {
    rotate inverted
}

cw_inverted() {
    rotate left
}

cw_left() {
    rotate normal
}

flip_normal() {
    rotate inverted
}

flip_right() {
    rotate left
}

flip_inverted() {
    rotate normal
}

flip_left() {
    rotate right
}

if [ "$1" == "cw" ]; then
    "cw_$current"
elif [ "$1" == "ccw" ]; then
    "ccw_$current"
elif [ "$1" == "flip" ]; then
    "flip_$current"
else
    rotate "$1"
fi

my_wallpaper
