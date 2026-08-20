#!/bin/bash
# Watch Hyprland IPC for monitor add/remove events and re-apply layout.
# This handles hotplug scenarios that exec= in monitors.conf doesn't cover.

SOCKET="${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"

# Startup: wait for Hyprland to finish its initial mode-setting, then run the
# layout script so any monitors stuck at 0x0 (DRM page-flip race) get fixed.
sleep 3
~/.config/hypr/scripts/monitors.sh

socat -u "UNIX-CONNECT:$SOCKET" - | while IFS= read -r event; do
    case "$event" in
        monitoradded*)
            # Wait for the DRM page-flip race to settle before retrying modes
            sleep 2
            ~/.config/hypr/scripts/monitors.sh
            ;;
        monitorremoved*)
            sleep 1
            ~/.config/hypr/scripts/monitors.sh
            ;;
    esac
done
