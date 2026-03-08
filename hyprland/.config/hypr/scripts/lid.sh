#!/bin/bash

# Only disable the laptop screen if at least one external monitor is active.
# This prevents a black screen if the lid is closed with no externals connected.

if [[ $1 == "close" ]]; then
  if hyprctl monitors | grep -qE "^Monitor DP"; then
    hyprctl keyword monitor "eDP-1, disable"
  fi
elif [[ $1 == "open" ]]; then
  hyprctl keyword monitor "eDP-1, 1920x1200@60, 0x1440, 1"
fi
