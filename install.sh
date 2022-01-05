#!/usr/bin/sh

# set -xe

# Install packages if the development environment is not manjaro/arch
# looking at you RHEL.
if ! grep -qE "manjaro|arch" "/etc/os-release"; then
    echo "I guess we're doing this the hard way..."
    echo "Installing nix package manager and packages"
    # Install nix
    curl -L https://nixos.org/nix/install | sh

  # Source nix
  . ~/.nix-profile/etc/profile.d/nix.sh

  nix-env -iA \
      nixpkgs.antibody \
      nixpkgs.bat \
      nixpkgs.bpytop \
      nixpkgs.clang_13 \
      nixpkgs.direnv \
      nixpkgs.fzf \
      nixpkgs.gdb \
      nixpkgs.git \
      nixpkgs.global \
      nixpkgs.gnumake \
      nixpkgs.htop \
      nixpkgs.jump \
      nixpkgs.neovim \
      nixpkgs.nodejs \
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

    # Add nix.zsh shell to login shells
    if grep -q "zsh" "/etc/shells"; then
        echo "zsh was found in /etc/shells";
    else
        echo "Adding zsh to /etc/shells"
        command -v zsh | sudo tee -a /etc/shells;
    fi

else
    echo "Thank goodness, I thought you were a troglodyte"
fi

# Install vim-plug if it isn't already installed
if [ -f ~/.vim/autoload/plug.vim ]; then
    echo "Installing vim-plug"
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
    echo "Found vim-plug, already installed"
fi


# Install dotfiles with gnu stow
stow gdb
stow git
stow nvim
stow shells
# stow tmux
stow vim

# Make important directories
[ -d ~/.vim/undodir ] && mkdir -p ~/.vim/undodir
[ -d ~/.vim/tmp ] && mkdir -p ~/.vim/tmp
[ -d ~/.config/nvim/undodir ] && mkdir -p ~/.config/nvim/undodir
[ -d ~/.config/nvim/tmp ] && mkdir -p ~/.config/nvim/tmp
[ -d ~/.cache/vim/ctags ] && mkdir -p ~/.cache/vim/ctags

# Install zsh plugins
antibody bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.sh

# Create vim directories
mkdir -p $HOME/.vim/undordir
mkdir -p $HOME/.vim/tmp

# Install vim/neovim plugin manager
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Make a symbolic link to vim config for neovim config
mkdir -p "$HOME/.config/nvim"
[ ! -f $HOME/.config/nvim/init.vim ] && ln -s "$HOME/.vimrc" "$HOME/.config/nvim/init.vim"

# Make a symbolic link to vim-plug install in .vim directory
mkdir -p "$HOME/.local/share/nvim/site/autoload"
[ ! -f $HOME/.local/share/nvim/site/autoload/plug.vim ] \
    && ln -s "$HOME/.vim/autoload/plug.vim" "$HOME/.local/share/nvim/site/autoload/plug.vim"

# Install neovim plugins
nvim --headless +PlugInstall +qall

# Instal NvChad
git clone https://github.com/NvChad/NvChad ~/.config/nvim
nvim +'hi NormalFloat guibg=#1e222a' +PackerSync

# Install terminal dotfiles
# if [ `uname -s` == 'Linux' ]; then
#     stow alacritty
# fi

echo
