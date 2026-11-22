#!/usr/bin/env sh

# --link-user-dirs: also symlink Downloads/Pictures/Videos/Music/Documents/
# Templates/Projects/Work to ~/pars and fix ~/.config/user-dirs.dirs (see
# link-user-dirs.sh). Opt-in: only makes sense on a machine with the ~/pars
# layout, not every machine this repo gets stowed on.
LINK_USER_DIRS=0
for arg in "$@"; do
    case "$arg" in
        --link-user-dirs) LINK_USER_DIRS=1 ;;
    esac
done

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

# Install dotfiles with GNU Stow (target = $HOME). The package list and the
# flags for each package live in packages.sh (shared with check-stow.sh).
DOTFILES="$(cd "$(dirname "$0")" && pwd)"
. "$DOTFILES/packages.sh"

if command -v stow >/dev/null 2>&1; then
    is_wayland || echo "Skipping Wayland packages: $STOW_WAYLAND $STOW_WAYLAND_NOFOLD (not a Wayland session)"
    is_x11 || echo "Skipping X11 packages: $STOW_X11 (not an X11 session)"

    for pkg in $(session_packages); do
        echo "Stowing $pkg"
        stow -v $(stow_flags "$pkg") -d "$DOTFILES" -t "$HOME" "$pkg" || echo "stow failed for $pkg (continuing)"
    done

    # Pick up the user units (gitea, voxtype); enabling them is left to the user
    if is_wayland && command -v systemctl >/dev/null 2>&1; then
        systemctl --user daemon-reload || true
    fi

    echo "Run ./check-stow.sh to verify every link."
else
    echo "GNU Stow not found; please install 'stow' and run 'stow -t \$HOME <pkg>' for each package"
fi

# Personal user-dir symlinks (Downloads, Pictures, Videos, etc. -> ~/pars) —
# opt-in via --link-user-dirs, see link-user-dirs.sh for details.
if [ "$LINK_USER_DIRS" = "1" ]; then
    sh "$(dirname "$0")/link-user-dirs.sh"
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

# Link vimrc as neovim init (only for a plain-vimscript neovim setup —
# skip if init.lua already exists, e.g. a LazyVim-style config, since
# neovim only loads one or the other and having both is a conflict)
if [ ! -f "$HOME/.config/nvim/init.vim" ] && [ ! -f "$HOME/.config/nvim/init.lua" ] && [ -f "$HOME/.vimrc" ]; then
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
