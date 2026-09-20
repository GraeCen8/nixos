#!/usr/bin/env sh
class="scratchpad"

if xdotool search --class "$class" windowkill >/dev/null 2>&1; then
    exit 0
else
    foot --app-id="$class" &
fi