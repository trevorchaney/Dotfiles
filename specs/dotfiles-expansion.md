# Dotfiles expansion (2026-11-22)

Bring the configs that are actually in use on this machine under the repo and
GNU Stow, without putting secrets or account details in the (public) repo.

## 1. Hyprland: migrate to the Lua config
Omarchy "quattro" (2026-09-17) switched Hyprland to `~/.config/hypr/hyprland.lua`
(confirmed in hyprland.log: "Using lua config"). The stowed `hyprland.conf`,
`envs.conf`, `looknfeel.conf` are no longer read.

- Add: `hyprland.lua bindings.lua looknfeel.lua input.lua autostart.lua
  monitors.lua .luarc.json`.
- Replace repo `hypridle.conf` / `hyprlock.conf` with the live versions
  (Omarchy updated the lock/wake commands; font changed to FiraCode).
- Remove dead files from the package: `hyprland.conf envs.conf looknfeel.conf
  autostart.conf bindings.conf input.conf monitors.conf` (kept in git history).
- Keep: `hyprsunset.conf xdph.conf scripts/` (`sleep.sh` is used by bindings.lua).

Audit of legacy settings vs Lua:
| Legacy setting | Status |
|---|---|
| Steam/Proton/nomacs/retroarch window rules | ported (hyprland.lua) |
| NVIDIA + screenshot-dir env | ported (autostart.lua) |
| input, monitors, bindings | ported |
| gaps 5/10 | equals Omarchy default |
| hyprexpo plugin block | plugin no longer loaded |
| lid switch -> scripts/lid.sh | superseded by Omarchy clamshell handling; not re-added |

Live files are replaced by symlinks atomically (`ln -s` + `mv -T`) so Hyprland's
config watcher never sees a missing file.

## 2. New stow packages (all `--no-folding`)
Each links only the named files, so logs/sockets/state the apps write next to
them never land in the repo.

| Package | Files |
|---|---|
| btop | .config/btop/btop.conf |
| kitty | .config/kitty/kitty.conf |
| ghostty | .config/ghostty/config |
| imv | .config/imv/config |
| herdr | .config/herdr/config.toml |
| voxtype | .config/voxtype/config.toml |
| newsboat | .config/newsboat/{config,urls} |
| fontconfig | .config/fontconfig/fonts.conf |
| xcompose | .XCompose |
| taskwarrior | .taskrc |
| systemd | .config/systemd/user/{gitea,voxtype}.service |
| aerc | .config/aerc/{aerc.conf,binds.conf} |

## 3. Privacy / security
Never tracked: `~/.env` (API key), `~/.msmtprc`, `~/.mailrc`,
`aerc/accounts.conf`, `aerc/gmail-pass`, `~/.config/gh`, histories, logs.

Mail passwords move to the GNOME keyring:
- `secret-tool store service gmail user <addr>` (value piped, never printed)
- aerc: `source-cred-cmd` / `outgoing-cred-cmd` -> `secret-tool lookup ...`
- msmtp: `password` -> `passwordeval "secret-tool lookup ..."`
- Verify lookup output matches the old password by comparison, then delete
  `aerc/gmail-pass` and the plaintext `password` line.

## 4. install.sh / README
- New packages stowed with `--no-folding`; desktop ones only under Wayland.
- README package table updated.

## Verification
- `stow -n` dry runs show no conflicts; every target is a symlink into the repo.
- Hyprland: `hyprctl reload` succeeds with no config errors; binds/rules present.
- systemd: `systemctl --user daemon-reload`; units still enabled.
- Mail: keyring lookups match the old password (hash compare).
- `git grep` on the staged tree finds no passwords/tokens.
