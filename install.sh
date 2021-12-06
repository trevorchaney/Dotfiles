#!/usr/bin/bash

# Install nix
curl -L https://nixos.org/nix/install | sh

# Source nix
. ~/.nix-profile/etc/profile.d/nix.sh

# Install packages
nix-env -iA \
    nixpkgs.zsh \
    nixpkgs.antibody \
    nixpkgs.git \
    nixpkgs.neovim \
    nixpkgs.tmux \
    nixpkgs.stow \
    nixpkgs.yarn \
    nixpkgs.fzf \
    nixpkgs.ripgrep \
    nixpkgs.bat \
    nixpkgs.gnumake \
    nixpkgs.clang \
    nixpkgs.alacritty \
    nixpkgs.gcc \
    nixpkgs.direnv

# Install dotfiles with gnu stow
stow git
stow nvim
stow tmux
stow vim
stow zsh

# Make zsh the login shell
command -v zsh | sudo tee -a /etc/shells

# Install zsh plugins
antibody bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.sh

# Install neovim plugins
nvim --headless +PlugInstall +qall

# Install terminal dotfiles
#[ `uname -s` == 'Linux' ] && stow alacritty
