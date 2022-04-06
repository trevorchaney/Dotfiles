# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# If running bash, include .bashrc if it exists
if [ -n "$BASH_VERSION" ]; then
    [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
fi

# If running zsh, include .zshrc if it exists
if [ -n "$ZSH_VERSION" ]; then
    [ -f "$HOME/.zshrc" ] && . "$HOME/.zshrc"
fi

# set PATH so it includes user's private bin if it exists
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"

# Configure keyboard bindings.
# setxkbmap -options found in /usr/share/X11/xkb/rules/evdev.list
setxkbmap -option 'caps:ctrl_modifier, shift:both_shiftlock'
xcape -e 'Caps_Lock=Escape'

# This is the stuff that came with Manjaro
export QT_QPA_PLATFORMTHEME="qt5ct"
export EDITOR=/usr/bin/vim
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

# fix "xdg-open fork-bomb" export your preferred browser from here
export BROWSER=/usr/bin/firefox

# Mount external drive if this is a virtual machine.
# vmhgfs-fuse -o auto_unmount,allow_other .host:/ $HOME/Desktop/external

if [ -e /home/tlc/.nix-profile/etc/profile.d/nix.sh ]; then . /home/tlc/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
