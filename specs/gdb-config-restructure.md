# GDB config restructure

## Goal
Replace the 5,400-line monolithic `gdb/.gdbinit` with a small, maintainable
XDG layout that keeps upstream gdb-dashboard as an unmodified, updatable file.

## Problems in the old file
- Embedded gdb-dashboard copy from 2021 (Python `SyntaxWarning`s on every start).
- ~2,250 lines of commented-out mammon/+HCU gdbinit and GEF.
- Dan Marinescu "STL views" macros: `pstring`/`pwstring` broken on the
  C++11 libstdc++ ABI; the rest superseded by libstdc++ pretty-printers.
- Manual libstdc++ printer registration block that never succeeds (Arch
  auto-loads `libstdc++.so.*-gdb.py` already).
- Go auto-load safe-path pointed at `/usr/lib/go`, but Go is installed by mise.
- Global `follow-fork-mode child` + `detach-on-fork off`.
- Redundant defaults, CRLF line endings, startup `echo` noise.
- No `history size`, debuginfod prompt every session.

## New layout (stow package `gdb`, target `$HOME`)
```
gdb/.config/gdb/gdbinit        settings; sources the two files below
gdb/.config/gdb/dashboard.gdb  upstream gdb-dashboard, pinned commit, unedited
gdb/.config/gdb/local.gdb      dashboard layout/styles, vimdb, gf2 guard, forks helper
```
`gdb/.gdbinit` is removed (and the `~/.gdbinit` symlink unstowed), since gdb
only reads `~/.gdbinit` when no XDG init file is found.

## Behaviour changes
- Fork-following becomes opt-in via the `follow-children` command.
- `set history size unlimited`, `set debuginfod enabled on`.
- `set disassembly-flavor intel`.
- Go safe-path covers `~/.local/share/mise/installs/go` and `/usr/lib/go`.

## Verification
- gdb starts with no warnings/errors.
- C++ test program: `print` of vector/string/map pretty-prints.
- Dashboard renders in a normal shell; disabled when parent is `gf2`.
- `vimdb` and `follow-children` defined.

## Updating the dashboard
```
curl -fL https://raw.githubusercontent.com/cyrus-and/gdb-dashboard/master/.gdbinit \
  -o gdb/.config/gdb/dashboard.gdb
```
