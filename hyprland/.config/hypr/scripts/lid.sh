#!/bin/bash
# Handle laptop lid open/close
# Usage: lid.sh close | lid.sh open

EXTERNAL_MONITORS=$(hyprctl monitors -j | jq '[.[] | select(.name != "eDP-1")] | length')

if [[ "$1" == "close" ]]; then
    if [[ "$EXTERNAL_MONITORS" -gt 0 ]]; then
        # External monitors connected — disable laptop screen, keep working
        hyprctl keyword monitor "eDP-1,disable"
    else
        # No external monitors — lock and hibernate
        loginctl lock-session
        sleep 1
        systemctl hibernate
    fi

elif [[ "$1" == "open" ]]; then
    if [[ "$EXTERNAL_MONITORS" -gt 0 ]]; then
        # Re-enable laptop screen to the left of the left external, vertically centered
        hyprctl keyword monitor "eDP-1,1920x1200@59.95,0x120,1.5"
    else
        # Only the laptop — use it as the sole display
        hyprctl keyword monitor "eDP-1,1920x1200@59.95,0x0,1.5"
    fi
fi
