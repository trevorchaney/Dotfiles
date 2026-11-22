
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

On a machine with the `~/pars` layout (personal data on a separate mount,
`~/pars` symlinked to it — see below), also pass `--link-user-dirs` to
symlink the standard home folders out to it:

```sh
./install.sh --link-user-dirs
```

## Packages

| Package     | Contents                                      | When to stow          |
|-------------|-----------------------------------------------|-----------------------|
| `bin`       | `~/bin/` scripts that shadow omarchy commands | Always                |
| `shells`    | `.bashrc`, `.zshrc`, `.shell_commons`, etc.   | Always                |
| `vim`       | `.vimrc`, `vim-plug`, spell, templates        | Always                |
| `nvim`      | Neovim spell files (shares `.vimrc`)          | Always                |
| `git`       | `.gitconfig`, global hooks, gitignore         | Always                |
| `tmux`      | `.tmux.conf`                                  | Always                |
| `ctags`     | `.ctags`                                      | Always                |
| `gdb`       | `.config/gdb/`, `.config/gf2_config.ini`      | Always                |
| `mise`      | `.config/mise/config.toml` (global tool list) | Always                |
| `btop`      | `.config/btop/btop.conf`                      | Always                |
| `newsboat`  | `.config/newsboat/` (`config`, `urls`)        | Always                |
| `taskwarrior` | `.taskrc`                                   | Always                |
| `aerc`      | `aerc.conf`, `binds.conf` (not accounts)      | Always                |
| `hyprland`  | `~/.config/hypr/` Lua config, hypridle/lock   | Wayland sessions only |
| `waybar`    | `~/.config/waybar/` (status bar layout + CSS) | Wayland sessions only |
| `kitty` `ghostty` | terminal configs                        | Wayland sessions only |
| `imv` `herdr` `voxtype` | app configs                       | Wayland sessions only |
| `fontconfig` | `.config/fontconfig/fonts.conf`              | Wayland sessions only |
| `xcompose`  | `.XCompose`                                   | Wayland sessions only |
| `systemd-user` | user units (gitea, voxtype); enable by hand | Wayland sessions only |
| `systemd`   | logind/sleep drop-ins (needs `/etc/systemd/`) | Copy manually         |
| `x11`       | `.Xresources`, i3 config                      | X11 sessions only     |
| `Windows`   | PowerShell profile, startup scripts           | Windows only          |
| `Makefiles` | C++ Makefile template                         | Copy manually         |
| `keyd`      | capslock remap config (needs `/etc/keyd/`)    | See below             |

`install.sh` automatically detects Wayland vs X11 and stows the right set.
The package list and each package's stow flags live in `packages.sh`; add
new packages there.

### Checking the links

`./check-stow.sh` verifies, without changing anything, that every managed
file is still the symlink stow would create. It catches configs that an app
or an Omarchy update replaced with a regular file (and says whether that file
still matches the repo copy), missing links, links pointing elsewhere, and
links into the repo whose file no longer exists. Exit status is non-zero when
something is wrong.

```sh
./check-stow.sh            # packages for this session
./check-stow.sh --all -q   # every package, problems only
./check-stow.sh kitty      # one package
```

## User Directories (`~/pars`)

On the primary machine, personal data (photos, videos, downloads, projects,
etc.) lives on a separate mount at `/mnt/state/pars`, with `~/pars`
symlinked to it — kept out of `$HOME` itself so it isn't tied to the OS
install. `./install.sh --link-user-dirs` (or `link-user-dirs.sh` directly)
symlinks the standard home folders out to it and updates
`~/.config/user-dirs.dirs` so XDG-aware apps (browsers, GTK/Qt file
pickers) recognize the real paths instead of falling back to bare `$HOME`:

| Home folder   | Symlinked to                       |
|---------------|-------------------------------------|
| `Downloads`   | `~/pars/storage/downloads`          |
| `Pictures`    | `~/pars/storage/pictures`           |
| `Videos`      | `~/pars/storage/videos`             |
| `Music`       | `~/pars/storage/music`              |
| `Documents`   | `~/pars/storage/documents`          |
| `Templates`   | `~/pars/resources/templates`        |
| `Projects`    | `~/pars/projects`                   |
| `Work`        | `~/pars/areas/ai`                   |

`Desktop` and `PublicShare` are intentionally left alone — not symlinked,
and their `XDG_*_DIR` entries aren't touched.

Some of these (`Pictures`, `Videos`, `camera`) may themselves be symlinks
further out to removable cold storage (an SD card, etc.) — chained symlinks
resolve transparently, so this is not a problem, but it does mean those
folders will appear empty if that media isn't currently mounted.

Safe to re-run: `link-user-dirs.sh` only replaces a target that doesn't
exist yet or is an already-empty directory — it never touches a target with
real content, and skips anything that's already a symlink. On a machine
without the `~/pars` layout, it's a no-op.

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

## Omarchy command overrides (`bin/`)

Scripts in `bin/bin/` are symlinked into `~/bin/` and shadow same-named
commands in `~/.local/share/omarchy/bin/`. This is the mechanism for fixing
omarchy bugs without modifying omarchy's source (which would be wiped on
`omarchy-update`).

`.bashrc` appends `~/bin` to the front of `$PATH` *after* omarchy's path
setup, so scripts here take precedence. Omarchy itself has no official
override mechanism — this is a `$PATH` shadowing convention.

Current overrides:

| Script | Fixes |
|--------|-------|
| `omarchy-restart-waybar` | Waits for the old waybar instance to fully exit before starting a new one, preventing two waybars from stacking when switching themes (race condition in `omarchy-restart-app`) |

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

## Not tracked (secrets and account details)

These stay local on purpose; never add them here:

- `~/.env` (API keys), `~/.config/gh/` (GitHub auth)
- Mail accounts: `~/.msmtprc`, `~/.mailrc`, `~/.config/aerc/accounts.conf`.
  Passwords live in the GNOME keyring (`secret-tool lookup service gmail user <addr>`),
  read by msmtp's `passwordeval` and aerc's `*-cred-cmd`.
- Shell/REPL histories, app logs, sockets and session files
