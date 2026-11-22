# packages.sh -- which stow packages exist and how each one is installed.
# Sourced by install.sh and check-stow.sh so they always agree. POSIX sh.

# Always stowed. Stow may "fold" these (link a whole directory).
STOW_CORE="bin ctags gdb git nvim shells tmux vim"

# Always stowed with --no-folding: only individual files are linked, so the
# app's own directory stays real and the logs, sockets, caches and backups it
# writes next to its config never land in this repo.
STOW_CORE_NOFOLD="mise btop newsboat taskwarrior aerc"

# Wayland (Hyprland) sessions only.
STOW_WAYLAND="hyprland waybar"
STOW_WAYLAND_NOFOLD="kitty ghostty imv herdr voxtype fontconfig xcompose systemd-user"

# X11 sessions only.
STOW_X11="x11"

# Not stowed into $HOME (copied by hand, see README): systemd keyd Windows Makefiles

is_wayland() { [ -n "$WAYLAND_DISPLAY" ] || [ "$XDG_SESSION_TYPE" = "wayland" ]; }
is_x11() { [ -n "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; }

# Extra stow flags for a package ("--no-folding" or nothing).
stow_flags() {
    case " $STOW_CORE_NOFOLD $STOW_WAYLAND_NOFOLD " in
        *" $1 "*) echo "--no-folding" ;;
    esac
}

# Packages install.sh stows in this session.
session_packages() {
    echo $STOW_CORE $STOW_CORE_NOFOLD
    if is_wayland; then echo $STOW_WAYLAND $STOW_WAYLAND_NOFOLD; fi
    if is_x11; then echo $STOW_X11; fi
}

all_packages() {
    echo $STOW_CORE $STOW_CORE_NOFOLD $STOW_WAYLAND $STOW_WAYLAND_NOFOLD $STOW_X11
}
