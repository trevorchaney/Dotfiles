#!/bin/bash
# Suspend on AC power, suspend-then-hibernate on battery.
if [[ $(cat /sys/class/power_supply/AC/online 2>/dev/null) == "1" ]]; then
    systemctl suspend
else
    systemctl suspend-then-hibernate
fi
