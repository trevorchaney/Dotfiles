#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Start Hyprland via uwsm on TTY1
if uwsm check may-start; then
  exec uwsm start hyprland.desktop
fi

# Nix profile (added by Nix installer)
if [ -e /home/tlc/.nix-profile/etc/profile.d/nix.sh ]; then . /home/tlc/.nix-profile/etc/profile.d/nix.sh; fi

# Start Hyprland via uwsm on TTY1
if uwsm check may-start; then
  exec uwsm start hyprland.desktop
fi

if [ -e /home/tlc/.nix-profile/etc/profile.d/nix.sh ]; then . /home/tlc/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
