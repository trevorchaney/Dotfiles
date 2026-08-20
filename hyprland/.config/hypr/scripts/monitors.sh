#!/bin/bash
# Shared monitor layout logic for init, reload, and lid events.
# Usage: monitors.sh [close|open]
# With no argument, auto-detects lid state.

# When called at startup via exec= (no arg, no prior run), give exec-once time
# to start waybar first so the restart script can kill it cleanly rather than
# racing with it.
STARTUP_FLAG=/tmp/hypr-monitors-started
if [[ -z "$1" && ! -f "$STARTUP_FLAG" ]]; then
    touch "$STARTUP_FLAG"
    sleep 1
fi

STATE_FILE="/tmp/hypr-monitor-workspaces"
FOCUS_FILE="${STATE_FILE}-focus"
EXTERNAL_MONITORS=$(hyprctl monitors -j | jq '[.[] | select(.name != "eDP-1")] | length')

# Determine lid state: argument overrides, otherwise read from /proc
if [[ -n "$1" ]]; then
    LID_STATE="$1"

    # Lid events happen before any shuffle, so save state now
    hyprctl monitors -j | jq -r '.[] | select(.name != "eDP-1") | "\(.name) \(.activeWorkspace.id)"' > "$STATE_FILE"
    hyprctl monitors -j | jq -r '.[] | select(.focused) | .name' > "$FOCUS_FILE"
elif grep -q closed /proc/acpi/button/lid/LID0/state 2>/dev/null; then
    LID_STATE="close"
else
    LID_STATE="open"
fi

if [[ "$LID_STATE" == "close" ]]; then
    WORKING_EXTERNALS=$(hyprctl monitors -j | jq '[.[] | select(.name != "eDP-1") | select(.width > 0)] | length')
    if [[ "$EXTERNAL_MONITORS" -gt 0 && ( "$1" == "close" || "$WORKING_EXTERNALS" -gt 0 ) ]]; then
        # Only disable the laptop screen when there's at least one working external to display on.
        # Guards against disabling eDP-1 when externals are stuck at 0x0 (no display at all).
        hyprctl keyword monitor "eDP-1,disable"

        # Restore workspace state saved from before the reload shuffle
        if [[ -f "$STATE_FILE" ]]; then
            while read -r monitor workspace; do
                hyprctl dispatch focusmonitor "$monitor"
                hyprctl dispatch workspace "$workspace"
            done < "$STATE_FILE"
        fi
    elif [[ -n "$1" ]]; then
        # Lid closed with no externals — suspend on AC, suspend-then-hibernate
        # on battery (hibernates after HibernateDelaySec if left closed).
        loginctl lock-session
        sleep 1
        ~/.config/hypr/scripts/sleep.sh
    else
        # Externals removed while lid was already closed.
        # Re-enable eDP-1 so there's an active display when the lid opens.
        hyprctl keyword monitor "eDP-1,1920x1200@59.95,0x0,1.5"
    fi
elif [[ "$LID_STATE" == "open" ]]; then
    if [[ "$EXTERNAL_MONITORS" -gt 0 ]]; then
        # Laptop centered below the left external monitor (DP-2)
        hyprctl keyword monitor "eDP-1,1920x1200@59.95,640x1440,1.5"
    else
        hyprctl keyword monitor "eDP-1,1920x1200@59.95,0x0,1.5"
    fi
    # eDP-1 can come up DPMS-off after being disabled during clamshell mode,
    # particularly if hypridle fired while the lid was closed and externals were
    # later unplugged. Force DPMS on so the display actually lights up.
    sleep 0.5
    hyprctl dispatch dpms on
fi

# Recovery for home monitors stuck at 0x0 after hotplug (aquamarine DRM atomic commit regression).
# Re-issuing the same keyword doesn't clear stuck DRM state. Disable→re-enable forces aquamarine
# to do a fresh CRTC teardown and reassignment, which mirrors startup behavior and actually works.
_fix_stuck_monitor() {
    local desc_fragment="$1"
    local full_spec="$2"

    local port width
    port=$(hyprctl monitors -j | jq -r --arg f "$desc_fragment" '.[] | select(.description | contains($f)) | .name')
    [[ -z "$port" ]] && return

    width=$(hyprctl monitors -j | jq -r --arg f "$desc_fragment" '.[] | select(.description | contains($f)) | .width')
    [[ "$width" != "0" ]] && return

    hyprctl keyword monitor "$port,disable"
    sleep 0.5
    hyprctl keyword monitor "$full_spec"
}

_fix_stuck_monitor "DELL P3223DE" "desc:Dell Inc. DELL P3223DE 4HNP1P3,2560x1440@59.95,0x0,1"
_fix_stuck_monitor "DELL G3223Q" "desc:Dell Inc. DELL G3223Q 6CQQ1P3,2560x1440@59.95,2560x0,1"

# Restart waybar so it appears on all monitors and remains clickable
omarchy-restart-waybar

# Restore focus to the monitor we started on
if [[ -f "$FOCUS_FILE" ]]; then
    FOCUSED_MONITOR=$(cat "$FOCUS_FILE")
    # If the focused monitor was eDP-1 and it's now disabled, fall back to DP-2
    if [[ "$FOCUSED_MONITOR" == "eDP-1" && "$LID_STATE" == "close" ]]; then
        FOCUSED_MONITOR="DP-2"
    fi
    hyprctl dispatch focusmonitor "$FOCUSED_MONITOR"
fi
