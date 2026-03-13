#!/usr/bin/env sh

export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# Make important directories (create if missing)
[ ! -d "$HOME/.config" ]               && mkdir -p "$HOME/.config"
[ ! -d "$HOME/.vim/undodir" ]          && mkdir -p "$HOME/.vim/undodir"
[ ! -d "$HOME/.vim/tmp" ]              && mkdir -p "$HOME/.vim/tmp"
[ ! -d "$HOME/.vim/vimwiki" ]          && mkdir -p "$HOME/.vim/vimwiki"
[ ! -d "$HOME/.config/nvim/undodir" ]  && mkdir -p "$HOME/.config/nvim/undodir"
[ ! -d "$HOME/.config/nvim/tmp" ]      && mkdir -p "$HOME/.config/nvim/tmp"
[ ! -d "$HOME/.cache/vim/ctags" ]      && mkdir -p "$HOME/.cache/vim/ctags"
[ ! -d "$HOME/.local/share/nvim/site/autoload" ] && mkdir -p "$HOME/.local/share/nvim/site/autoload"

# Install dotfiles with GNU Stow (target = $HOME)
if command -v stow >/dev/null 2>&1; then
    # Core packages — always stow
    for pkg in ctags gdb git nvim shells tmux vim; do
        echo "Stowing $pkg"
        stow -v -t "$HOME" "$pkg" || echo "stow failed for $pkg (continuing)"
    done

    # Wayland/Hyprland — stow if running Wayland
    if [ -n "$WAYLAND_DISPLAY" ] || [ "$XDG_SESSION_TYPE" = "wayland" ]; then
        echo "Stowing hyprland"
        stow -v -t "$HOME" hyprland || echo "stow failed for hyprland (continuing)"
    else
        echo "Skipping hyprland (not a Wayland session)"
    fi

    # X11 — stow if running X11
    if [ -n "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
        echo "Stowing x11"
        stow -v -t "$HOME" x11 || echo "stow failed for x11 (continuing)"
    else
        echo "Skipping x11 (not an X11 session)"
    fi
else
    echo "GNU Stow not found; please install 'stow' and run 'stow -t \$HOME <pkg>' for each package"
fi

# Install vim-plug for vim (symlinked by stow above, but download if missing)
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

# Link vim-plug into neovim autoload
if [ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ] && [ -f "$HOME/.vim/autoload/plug.vim" ]; then
    ln -s "$HOME/.vim/autoload/plug.vim" "$HOME/.local/share/nvim/site/autoload/plug.vim"
fi

# Link vimrc as neovim init (neovim shares vim config)
if [ ! -f "$HOME/.config/nvim/init.vim" ] && [ -f "$HOME/.vimrc" ]; then
    ln -s "$HOME/.vimrc" "$HOME/.config/nvim/init.vim"
fi

# Install neovim plugins
if command -v nvim >/dev/null 2>&1; then
    echo "Installing neovim plugins"
    nvim --headless +PlugInstall +qall || echo "nvim PlugInstall failed"
fi

# starship prompt — install if missing
if ! command -v starship >/dev/null 2>&1; then
    echo ""
    echo "NOTE: starship is not installed. To install:"
    echo "  sudo pacman -S starship"
fi

# keyd (capslock → tap:Escape / hold:Ctrl) — requires root, manual step
if ! command -v keyd >/dev/null 2>&1; then
    echo ""
    echo "NOTE: keyd is not installed. To enable capslock remapping (tap=Escape, hold=Ctrl):"
    echo "  sudo pacman -S keyd"
    echo "  sudo mkdir -p /etc/keyd"
    echo "  sudo cp $(pwd)/keyd/default.conf /etc/keyd/default.conf"
    echo "  sudo systemctl enable --now keyd"
fi

echo
echo "Done."
