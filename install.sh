#!/usr/bin/bash

set -xi

# Install nix
curl -L https://nixos.org/nix/install | sh

# Source nix
. ~/.nix-profile/etc/profile.d/nix.sh

# Install packages
nix-env -iA \
    nixpkgs.antibody \
    nixpkgs.bat \
    nixpkgs.clang \
    nixpkgs.direnv \
    nixpkgs.doas \
    nixpkgs.fzf \
    nixpkgs.gcc \
    nixpkgs.git \
    nixpkgs.gnumake \
    nixpkgs.neovim \
    nixpkgs.ripgrep \
    nixpkgs.stow \
    nixpkgs.tmux \
    nixpkgs.yarn \
    nixpkgs.zsh

# Install dotfiles with gnu stow
stow git
stow nvim
stow tmux
stow vim
stow zsh

if [ `$TERM` == 'bash' ]; then
    . $HOME/.bashrc
elif [ `$TERM` == 'zsh' ]; then
    . $HOME/.zshrc
fi

# Make zsh the login shell
command -v zsh | sudo tee -a /etc/shells

# Install zsh plugins
#antibody bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.sh

# Install neovim plugins
ln -s $HOME/.vimrc $HOME/.config/nvim/init.vim
nvim --headless +PlugInstall +qall

# Install terminal dotfiles
# if [ `uname -s` == 'Linux' ]; then
#     stow alacritty
# fi
