-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Removed the default HEY webapp, so unbind its keybindings too (were:
-- Calendar, Email, New email).
hl.unbind("SUPER + SHIFT + C")
hl.unbind("SUPER + SHIFT + E")
hl.unbind("SUPER + SHIFT + ALT + E")

-- Free keys.
o.bind("SUPER + D", "Draw.io", { launch = "drawio" })
o.bind("SUPER + R", "Reload Hyprland", "hyprctl reload")
o.bind("SUPER + ALT + L", "Sleep", "~/.config/hypr/scripts/sleep.sh")

-- Was: Omawrite. Rebind SUPER+SHIFT+W to Typora.
hl.unbind("SUPER + SHIFT + W")
o.bind("SUPER + SHIFT + W", "Typora", "uwsm-app -- typora --enable-wayland-ime")

-- Was: Google Maps. Rebind SUPER+SHIFT+S to a region screenshot (saves to
-- OMARCHY_SCREENSHOT_DIR, copies to clipboard, and notifies — set in autostart.lua).
hl.unbind("SUPER + SHIFT + S")
o.bind("SUPER + SHIFT + S", "Screenshot (region)", "omarchy-capture-screenshot region")

-- No physical Print key on this keyboard — remap Print-based captures to Grave.
hl.unbind("PRINT")
hl.unbind("ALT + PRINT")
hl.unbind("SUPER + PRINT")
o.bind("SUPER + GRAVE", "Screenrecording", "omarchy-menu screenrecord")
o.bind("SUPER + SHIFT + GRAVE", "Color picker", "pkill hyprpicker || hyprpicker -a")

-- Dictation keys from before Alt + Space and Right Alt became the defaults.
-- Remove these lines to give the keys back to applications.
if o.dictation_installed and o.dictation_installed() then
  o.bind("SUPER + CTRL + X", "Toggle dictation", "omarchy-dictation toggle")
  o.bind_hold("F9", "Start dictation (push-to-talk)", "omarchy-dictation start", "Stop dictation (push-to-talk)", "omarchy-dictation stop")
end
