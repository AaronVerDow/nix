#!/usr/bin/env bash
set -exuo pipefail

# Configure these to match your hardware (names taken from `xinput` output).
DEVICES='ELAN06FA:00 04F3:327E Touchpad
Wacom HID 53BC Finger'

# Auto detect primary display
XDISPLAY=`xrandr --current | grep primary | sed -e 's/ .*//g'`

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

rotate() {
	rotation=$1
	if ! echo $rotation | grep -Eq '(normal|inverted|left|right)'; then
		echo "Invalid rotation!"
		return 1
	fi

	xrandr --output $XDISPLAY --rotate $rotation
	while read device; do
		$rotation "$device"
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

if [ $1 == "cw" ]; then
	cw_$current
elif [ "$1" == "ccw" ]; then
	ccw_$current
else
	rotate $1
fi
