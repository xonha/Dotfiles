# Dotfiles

Arch Linux dotfiles managed with GNU Stow. Run `stow .` from repo root to deploy.

## Index

- [Overview](docs/overview.md) — what this repo does and covers
- [Constitution](docs/constitution.md) — purpose, principles, philosophy
- [Infrastructure](docs/infra.md) — machines, Tailscale network, how to reach each host
- [devbox](docs/devbox.md) — Arch Linux dev container on Bazzite (Podman + systemd)
- [n8n](docs/n8n-bazzite.md) — n8n self-hosted on Bazzite (Podman + Quadlet)
- [Setup notes](.setup/README.md) — wake-from-suspend, udev rules, hardware quirks
- [Stow layout](#stow-layout) — directory map for this repo

## Stow Layout

| Path | Purpose |
|------|---------|
| `.config/hypr/` | Hyprland WM (`monitors.conf` gitignored — machine-specific) |
| `.config/kitty/` | Kitty terminal |
| `.config/nvim/` | Neovim — LazyVim (`lazy-lock.json` gitignored) |
| `.config/waybar/` | Waybar status bar |
| `.config/mako/` | Mako notifications |
| `.config/opencode/` | OpenCode |
| `.config/scripts/` | Custom shell scripts |
| `.tmux.conf` | Tmux |
| `.zshrc` / `.zshenv` | Zsh + Powerlevel10k (`.p10k.zsh`) |
| `.keyd.conf` | Keyd keyboard remapping |
| `.ssh/config` | SSH host aliases |
| `.docker/Dockerfile` | devbox container image |
| `.setup/` | Setup scripts sourced by `.install.sh` |

## Adding Dotfiles

Drop file under repo root at its `$HOME`-relative path, then re-run `stow .`.
