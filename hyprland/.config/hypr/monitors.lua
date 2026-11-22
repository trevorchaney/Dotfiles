-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1.25

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Desk layout: two external Dells + laptop, matched by description so port
-- reassignments after reboots don't break the arrangement.
-- Dell P3223DE = left, Dell G3223Q = right, eDP-1 (laptop) = below left external.
-- Fixed offset (not centered) to match the original desk layout. With no
-- externals connected this just shifts the compositor's coordinate origin —
-- harmless with a single monitor.
hl.monitor({ output = "desc:Dell Inc. DELL P3223DE 4HNP1P3", mode = "2560x1440@59.95", position = "0x0", scale = 1 })
hl.monitor({ output = "desc:Dell Inc. DELL G3223Q 6CQQ1P3", mode = "2560x1440@59.95", position = "2560x0", scale = 1 })
hl.monitor({ output = "eDP-1", mode = "1920x1200@59.95", position = "640x1440", scale = omarchy_monitor_scale })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
