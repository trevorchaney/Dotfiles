#!/bin/bash
# Save workspace state before reload so monitors.sh can restore it after.

STATE_FILE="/tmp/hypr-monitor-workspaces"

# Save current state while everything is still correct
hyprctl monitors -j | jq -r '.[] | select(.name != "eDP-1") | "\(.name) \(.activeWorkspace.id)"' > "$STATE_FILE"

# Also save which monitor is focused
hyprctl monitors -j | jq -r '.[] | select(.focused) | .name' > "${STATE_FILE}-focus"

hyprctl reload
