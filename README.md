# Dotfiles

Personal dotfiles organized as GNU Stow packages, designed for Arch Linux /
Hyprland. Each top-level directory is a stow package that symlinks into `$HOME`.

## Quick install

Prerequisites: `git`, `stow`, `curl`, `nvim`

```sh
git clone https://github.com/trevorchaney/Dotfiles.git ~/Dotfiles
cd ~/Dotfiles
./install.sh
```

## Packages

| Package     | Contents                                      | When to stow          |
|-------------|-----------------------------------------------|-----------------------|
| `shells`    | `.bashrc`, `.zshrc`, `.shell_commons`, etc.   | Always                |
| `vim`       | `.vimrc`, `vim-plug`, spell, templates        | Always                |
| `nvim`      | Neovim spell files (shares `.vimrc`)          | Always                |
| `git`       | `.gitconfig`, global hooks, gitignore         | Always                |
| `tmux`      | `.tmux.conf`                                  | Always                |
| `ctags`     | `.ctags`                                      | Always                |
| `gdb`       | `.gdbinit`                                    | Always                |
| `hyprland`  | `~/.config/hypr/` (full Hyprland config)      | Wayland sessions only |
| `x11`       | `.Xresources`, i3 config                      | X11 sessions only     |
| `Windows`   | PowerShell profile, startup scripts           | Windows only          |
| `Makefiles` | C++ Makefile template                         | Copy manually         |
| `keyd`      | capslock remap config (needs `/etc/keyd/`)    | See below             |

`install.sh` automatically detects Wayland vs X11 and stows the right set.

## Keyboard remapping (Wayland)

Capslock is remapped via `keyd` (kernel-level, works on Wayland):
- **Tap** → Escape
- **Hold** → Ctrl

Both Shifts together → Caps Lock (handled by Hyprland `kb_options`).

To install:
```sh
sudo pacman -S keyd
sudo mkdir -p /etc/keyd
sudo cp keyd/default.conf /etc/keyd/default.conf
sudo systemctl enable --now keyd
```

On X11, `setxkbmap` + `xcape` configs are in the `x11/` package instead.

## Vim / Neovim

Neovim shares the vim config: `~/.config/nvim/init.vim` is symlinked to
`~/.vimrc`. Plugins are managed by vim-plug (included in the repo at
`vim/.vim/autoload/plug.vim`). Run `:PlugInstall` inside vim/nvim after
first install, or let `install.sh` do it headlessly.

## Git package notes

`git/server-hooks/` and `git/HOOKS_README.md` are reference material and are
excluded from stowing via `.stow-local-ignore`. Copy server hooks manually
to any git server repo's `hooks/` directory.

## Why GNU Stow?

Stow creates symlinks from package directories into a target (`$HOME`). It's
simple, transparent, and easy to reason about. Each package can be stowed or
unstowed independently, making it easy to maintain separate X11 and Wayland
configurations on the same machine.

## Troubleshooting

- **Stow conflicts**: if stow reports a conflict, the target file already
  exists and is not a symlink. Back it up and remove it, then re-run stow.
- **CRLF errors in shell/vim**: repo enforces LF via `.gitattributes`. If you
  see `^M` errors after cloning, run:
  `find . -type f -name "*.vim" -o -name "*.sh" | xargs sed -i 's/\r//'`
- **jump not found**: install `jump` from the AUR (`yay -S jump`), or the
  jump eval in `.bashrc`/`.zshrc` is safely guarded and will silently skip.
