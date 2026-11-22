# Stow link checker

## Goal
A read-only script that reports whether the files stow manages in `$HOME` are
the symlinks stow would create, or have turned into regular files, wrong links,
missing links or broken links (e.g. after an app or Omarchy update replaced a
symlink with a copy).

## Design
- `packages.sh` (POSIX sh): single source of truth for package names and how
  each is stowed. Sourced by both `install.sh` and `check-stow.sh`.
  - `STOW_CORE` / `STOW_CORE_NOFOLD`: always
  - `STOW_WAYLAND` / `STOW_WAYLAND_NOFOLD`: Wayland sessions
  - `STOW_X11`: X11 sessions
- `check-stow.sh` (bash):
  1. For each selected package run `stow -n -v [--no-folding] -t TARGET pkg`
     (simulation, changes nothing) and classify its output:
     | stow says | reported as |
     |---|---|
     | `LINK: X => …` | missing link |
     | `cannot stow … over existing target X since neither a link nor a directory` | regular file (identical / differs from repo copy) |
     | `existing target is not owned by stow: X` | link pointing outside the repo |
     | `existing target is stowed to a different package: X => …` | owned by another package |
  2. Broken-link scan: symlinks under the packages' target directories that
     point into the repo but no longer resolve (stow does not report these).
  3. Print a per-package result and fix hints; exit 1 if anything is wrong.
- Options: `--all` (every package, regardless of session), `--target DIR`
  (default `$HOME`; used for testing), `-q` (problems only), package names to
  check a subset.

## Verification
- On this machine: all session packages report OK.
- In a scratch target: regular file (identical and different), foreign link,
  missing link and broken link each reported correctly with exit code 1.
- `install.sh` still parses (`sh -n`) and stows the same packages as before.
