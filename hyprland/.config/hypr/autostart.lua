-- Extra autostart processes.
o.launch_on_start("hyprsunset")

-- Save screenshots to a custom directory (read by omarchy-capture-screenshot).
hl.env("OMARCHY_SCREENSHOT_DIR", os.getenv("HOME") .. "/pars/storage/pictures/screenshots")

-- NVIDIA (Turing+ with GSP firmware).
hl.env("NVD_BACKEND", "direct")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")
