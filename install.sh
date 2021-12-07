#!/usr/bin/bash

set -xe

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
    nixpkgs.jump \
    nixpkgs.neovim \
    nixpkgs.ripgrep \
    nixpkgs.stow \
    nixpkgs.tmux \
    nixpkgs.vim \
    nixpkgs.yarn \
    nixpkgs.zsh

# Install dotfiles with gnu stow
stow git
stow nvim
stow tmux
stow vim
stow shells

# Add nix.zsh shell to login shells
if [ ! -z $(grep "$STRING" "$FILE") ]; then
    echo "zsh was found in shells";
    command -v zsh | sudo tee -a /etc/shells;
fi

# Run the following to make zsh the user's login shell
#$ sudo chsh -s `which zsh` $USER

# Install zsh plugins
# antibody bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.sh

# Make a symbolic link to vim config for neovim config
ln -s $HOME/.vimrc $HOME/.config/nvim/init.vim

# Install neovim plugins
nvim --headless +PlugInstall +qall

# Install terminal dotfiles
# if [ `uname -s` == 'Linux' ]; then
#     stow alacritty
# fi
