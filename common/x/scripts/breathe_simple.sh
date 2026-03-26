#!/usr/bin/env bash

# Script to periodically adjust AwesomeWM gaps between 10 and 20
# This creates a "breathe" effect by smoothly varying the gap size

GAP_MIN=10
GAP_MAX=30
SLEEP_TIME=180
STEP_SIZE=1

# Oscillate between min and max
while true; do
    # Increase from min to max
    for ((gap=GAP_MIN; gap<=GAP_MAX; gap+=STEP_SIZE)); do
        awesome-client '
            local beautiful = require("beautiful")
            local awful = require("awful")
            beautiful.useless_gap = '$gap'
            for s in screen do
                awful.layout.arrange(s)
            end
        ' 2>/dev/null
        sleep $SLEEP_TIME
    done
    
    # Decrease from max to min
    for ((gap=GAP_MAX-STEP_SIZE; gap>=GAP_MIN; gap-=STEP_SIZE)); do
        awesome-client '
            local beautiful = require("beautiful")
            local awful = require("awful")
            beautiful.useless_gap = '$gap'
            for s in screen do
                awful.layout.arrange(s)
            end
        ' 2>/dev/null
        sleep $SLEEP_TIME
    done
done
