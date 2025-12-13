# Dotfiles

These are my personal dotfiles organized as GNU Stow packages so they
can be bootstrapped onto a new system quickly. The repository is
intended to be symlinked into your `$HOME` using `stow` (see
Installation below).

This README documents the supported install flow, expectations, and a
recommendation on using GNU Stow vs configuration management tools like
Ansible or Vagrant.

## Quick install (bootstrap)

Prerequisites on the target system:

- `git` (to clone this repo)
- `stow` (GNU Stow) — used to symlink package directories into `$HOME`
- `curl` (for plugin bootstrapping)
- Optional: `nvim`, `antibody`, etc. for post-install steps

To bootstrap a new system (example):

```sh
git clone https://github.com/trevorchaney/Dotfiles.git ~/Dotfiles
cd ~/Dotfiles
./install.sh
```

The `install.sh` script will:

- Create needed directories (vim/Neovim undo, tmp, etc.)
- Attempt to install `nix` packages if the environment is not a known
	Arch/Debian family (see script behavior)
- Install vim-plug and Neovim plugins (if `nvim` present)
- Invoke GNU Stow to symlink packages: `gdb`, `git`, `nvim`, `shells`,
	`tmux`, `vim` into `$HOME` (only if `stow` is installed)

If you prefer to run `stow` yourself, you can do so manually from the
repo root:

```sh
cd ~/Dotfiles
stow -t $HOME git nvim vim shells tmux gdb
```

## Why GNU Stow?

GNU Stow is a small, focused tool that manages symlinks. It's:

- Simple and transparent — it creates symlinks from package dirs into a
	target directory and is easy to reason about.
- Lightweight — no agent, no remote execution model, no provisioning
	runtime on target machines.
- Easy to version and review — your dotfiles repository contains the
	canonical files; stow only manages symlinks.

When to use Stow vs Ansible / Vagrant / other CM tools:

- Use GNU Stow if:
	- You only need to manage dotfiles (user-level files) and symlink
		them into `$HOME`.
	- You want a reproducible, reviewable dotfiles repository with low
		operational complexity.
	- You prefer manual or ad-hoc bootstrapping; stow is excellent for
		quick personal setups.

- Consider Ansible (or other config management) if:
	- You need to provision full system state: install packages, enable
		services, manage system users, configure system files outside of
		`$HOME` (e.g., `/etc`), and do this across many machines.
	- You want idempotent remote provisioning with richer modules and
		inventory management.

- Consider Vagrant if:
	- You want reproducible development VMs (local virtual machines)
		for testing or development. Vagrant wraps provisioners and VM
		tooling, it's not a dotfiles manager per se.

In short: for dotfiles-only workflows, GNU Stow is a good fit. For
multi-host system provisioning, Ansible (or similar) is a better fit.

## Advanced: combining tools

It's common to combine approaches:

- Use Ansible to bootstrap a system (install packages, system-level
	configuration) and then use Ansible to `git clone` this dotfiles
	repo and run `stow` for per-user symlinks.
- Use Vagrant for development VM reproducibility and run Ansible as a
	provisioner inside the VM to apply the same playbooks.

## Troubleshooting & common issues

- If `stow` tries to symlink over existing files, you'll see errors —
	either remove/conflict those files or use `stow --adopt` or backup
	existing files before running `stow`.
- On Windows, use WSL or Git Bash for best compatibility with symlinks
	and utilities; native Windows symlink behavior requires elevated
	permissions or special flags.
- If `install.sh` fails because of missing utilities, install them or
	run the steps manually; the script is conservative and will print
	guidance when tools are missing.

## Next steps / suggestions

- Add a small `tests/` harness that runs `stow -t $PWD/test-home <pkg>`
	to validate package mappings without touching your real home.
- Add a `README.install.md` with more troubleshooting steps and known
	platform caveats (WSL vs native Windows vs macOS differences).

---

If you'd like, I can:
- Add the `tests/` harness and `README.install.md` now, or
- Create a brief `stow` usage guide for your `git/` package layout.

Ping me which next step you prefer.
