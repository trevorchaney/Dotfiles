#!/usr/bin/bash

# set -xe

# Install nix
curl -L https://nixos.org/nix/install | sh

# Source nix
. $HOME/.nix-profile/etc/profile.d/nix.sh

# Install packages
nix-env -iA \
    nixpkgs.antibody \
    nixpkgs.bat \
    nixpkgs.clang_13 \
    nixpkgs.direnv \
    nixpkgs.doas \
    nixpkgs.fzf \
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
#stow nvim
#stow tmux
stow vim
stow shells

# Add nix.zsh shell to login shells
if grep -q "zsh" "/etc/shells"; then
    echo "zsh was found in /etc/shells";
else
    echo "Adding zsh to /etc/shells"
    command -v zsh | sudo tee -a /etc/shells;
fi

## Install Oh-My-Zsh
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

# Run the following to make zsh the user's login shell
#$ sudo chsh -s `which zsh` $USER

# Install zsh plugins
# antibody bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.sh

# Make a symbolic link to vim config for neovim config
ln -s "$HOME/.vimrc" "$HOME/.config/nvim/init.vim"

# Install neovim plugins
nvim --headless +PlugInstall +qall

# Install terminal dotfiles
# if [ `uname -s` == 'Linux' ]; then
#     stow alacritty
# fi