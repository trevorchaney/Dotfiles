
#!/usr/bin/env sh

# set -xe

troglodyte=0
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# Make important directories (create if missing)
[ ! -d "$HOME/.vim/undodir" ] && mkdir -p "$HOME/.vim/undodir"
[ ! -d "$HOME/.vim/tmp" ] && mkdir -p "$HOME/.vim/tmp"
[ ! -d "$HOME/.vim/vimwiki" ] && mkdir -p "$HOME/.vim/vimwiki"
[ ! -d "$HOME/.config/nvim/undodir" ] && mkdir -p "$HOME/.config/nvim/undodir"
[ ! -d "$HOME/.config/nvim/tmp" ] && mkdir -p "$HOME/.config/nvim/tmp"
[ ! -d "$HOME/.cache/vim/ctags" ] && mkdir -p "$HOME/.cache/vim/ctags"

# Install packages if the development environment is not manjaro/arch
# looking at you RHEL.
if ! grep -qE "manjaro|arch|debian|raspbian" "/etc/os-release"; then
    troglodyte=1
    echo "I guess we're doing this the hard way..."
    echo "Installing nix package manager and packages"
    # Install nix
    curl -L https://nixos.org/nix/install | sh

  # Source nix
  . ~/.nix-profile/etc/profile.d/nix.sh

  nix-env -iA \
      nixpkgs.antibody \
      nixpkgs.atool \
      nixpkgs.bat \
      nixpkgs.bpytop \
      nixpkgs.clang_13 \
      nixpkgs.cppcheck \
      nixpkgs.direnv \
      nixpkgs.fzf \
      nixpkgs.gdb \
      nixpkgs.gh \
      nixpkgs.git \
      nixpkgs.global \
      nixpkgs.gnumake \
      nixpkgs.htop \
      nixpkgs.jump \
      nixpkgs.llvmPackages_13.libclang \
      nixpkgs.neofetch \
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
      nixpkgs.xcape \
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
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    if command -v curl >/dev/null 2>&1; then
        echo "Installing vim-plug"
        curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    else
        echo "curl not found; please install curl and re-run install.sh to install vim-plug"
    fi
else
    echo "Found vim-plug, already installed"
fi

# Remove directories that the install process created, these create conflicts for stow


# Install dotfiles with GNU Stow (target = $HOME)
if command -v stow >/dev/null 2>&1; then
    for pkg in gdb git nvim shells tmux vim; do
        echo "Stowing $pkg"
        stow -v -t "$HOME" "$pkg" || echo "stow failed for $pkg (continuing)"
    done
else
    echo "GNU Stow not found; please install 'stow' and run 'stow -t \$HOME <pkg>' for each package"
fi


# Install zsh plugins (if antibody present)
if command -v antibody >/dev/null 2>&1 && [ -f "$HOME/.zsh_plugins.txt" ]; then
    antibody bundle < "$HOME/.zsh_plugins.txt" > "$HOME/.zsh_plugins.sh" || echo "antibody failed"
fi

# Make a symbolic link to vim config for neovim config
mkdir -p "$HOME/.config/nvim"
if [ ! -f "$HOME/.config/nvim/init.vim" ] && [ -f "$HOME/.vimrc" ]; then
    ln -s "$HOME/.vimrc" "$HOME/.config/nvim/init.vim"
else
    echo "~/.config/nvim/init.vim already exists or ~/.vimrc missing, skipping symbolic linking"
fi

# Make a symbolic link to vim-plug install in neovim autoload
mkdir -p "$HOME/.local/share/nvim/site/autoload"
if [ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ] && [ -f "$HOME/.vim/autoload/plug.vim" ]; then
    ln -s "$HOME/.vim/autoload/plug.vim" "$HOME/.local/share/nvim/site/autoload/plug.vim"
else
    echo "~/.local/share/nvim/site/autoload/plug.vim already exists or source plug.vim missing, skipping symbolic linking"
fi

# Install neovim plugins if nvim is available
if command -v nvim >/dev/null 2>&1; then
    nvim --headless +PlugInstall +qall || echo "nvim PlugInstall failed or returned non-zero"
fi

# Install NvChad

if [ "$troglodyte" = "1" ]; then
    if [ ! -d "$HOME/.config/nvim" ]; then
        git clone https://github.com/NvChad/NvChad "$HOME/.config/nvim" || echo "Failed to clone NvChad"
    else
        echo "NvChad already present at $HOME/.config/nvim"
    fi
    if command -v nvim >/dev/null 2>&1; then
        nvim +'hi NormalFloat guibg=#1e222a' +PackerSync || echo "NvChad PackerSync failed"
    fi
fi

echo
