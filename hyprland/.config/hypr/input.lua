-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.

-- Keyboard layout and options.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input
hl.config({
  input = {
    kb_variant = "dvorak",

    -- Caps Lock is remapped by keyd, not Hyprland's compose-key handling —
    -- leave this empty so the two don't fight over the same key.
    kb_options = "",

    repeat_rate = 40,
    repeat_delay = 600,

    touchpad = {
      -- Use natural (inverse) scrolling. Hyprland has no per-axis option —
      -- this flips both vertical and horizontal.
      natural_scroll = true,

      -- Use two-finger clicks for right-click instead of lower-right corner.
      clickfinger_behavior = true,

      -- Control the speed of your scrolling.
      scroll_factor = 0.25,

      -- 1-finger tap = left, 2-finger tap = right, 3-finger tap = middle click.
      tap_button_map = "lrm",
    },
  },
})

-- Enable touchpad gestures for changing workspaces.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
