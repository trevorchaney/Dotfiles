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
    nixpkgs.bpytop \
    nixpkgs.clang_13 \
    nixpkgs.direnv \
    nixpkgs.doas \
    nixpkgs.fzf \
    nixpkgs.git \
    nixpkgs.gnumake \
    nixpkgs.htop \
    nixpkgs.jump \
    nixpkgs.neovim \
    nixpkgs.ranger \
    nixpkgs.ripgrep \
    nixpkgs.silver-searcher \
    nixpkgs.stow \
    nixpkgs.tmux \
    nixpkgs.toilet \
    nixpkgs.valgrind \
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

# Install zsh plugins
# antibody bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.sh

# Install vim/neovim plugin manager
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Make a symbolic link to vim config for neovim config
mkdir -p "$HOME/.config/nvim"
[ ! -f $HOME/.config/nvim/init.vim ] && ln -s "$HOME/.vimrc" "$HOME/.config/nvim/init.vim"

# Make a symbolic link to vim-plugs install in vim directory
mkdir -p "$HOME/.local/share/nvim/site/autoload"
[ ! -f $HOME/.local/share/nvim/site/autoload/plug.vim ] && ln -s "$HOME/.vim/autoload/plug.vim" "$HOME/.local/share/nvim/site/autoload/plug.vim"

# Install neovim plugins
nvim --headless +PlugInstall +qall

# Install terminal dotfiles
# if [ `uname -s` == 'Linux' ]; then
#     stow alacritty
# fi
