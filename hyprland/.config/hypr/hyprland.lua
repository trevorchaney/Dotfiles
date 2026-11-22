-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Steam/Proton game window rules.
-- Reason: older Hyprland had a bug where tiled game windows interacting with
-- moveFocusTo keybinds could crash the compositor. Floating these windows
-- avoids triggering the layout bug. Kept as cheap insurance; the underlying
-- Hyprland bug may be fixed in this version.
o.window({ class = "^(steam)$", title = "negative:^(Steam)$" }, { float = true })
o.window("^(org.nomacs.ImageLounge)$", { float = true })
o.window("^(steam_app_.*)$", { float = true, suppress_event = "maximize" })
o.window("^(gamescope)$", { float = true })
o.window("^(retroarch)$", { float = true })
