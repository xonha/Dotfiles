# Project Overview

Personal dotfiles and environment setup for an Arch Linux + Hyprland workstation,
with support for a Bazzite home server and a Windows/WSL work machine — all connected via Tailscale.

## What this repo does

- **Deploys config files** via GNU Stow (`stow .` from repo root symlinks everything into `$HOME`)
- **Installs packages** via `yay` — server tools, desktop GUI stack, and AUR packages
- **Bootstraps a fresh Arch install** end-to-end with `.install.sh`
- **Documents the full environment** — containers, infra, editor setup, and system quirks

## What it covers

| Area | Details |
|------|---------|
| Window manager | Hyprland (binds, idle, lock, paper, dynamic monitors) |
| Terminal | Kitty |
| Editor | Neovim with LazyVim |
| Shell | Zsh + Powerlevel10k + plugins |
| Multiplexer | Tmux |
| AI assistants | Claude Code + OpenCode |
| Keyboard | Keyd remapping |
| Status bar | Waybar |
| Notifications | Mako |
| Home server | Bazzite host running devbox + n8n via Podman |
| Networking | Tailscale across all machines |

## Docs index

- [Constitution](constitution.md) — principles and philosophy
- [Infrastructure](infra.md) — machines, Tailscale, SSH aliases
- [devbox](devbox.md) — Arch Linux dev container on Bazzite
- [n8n](n8n-bazzite.md) — n8n self-hosted on Bazzite
- [Setup notes](../.setup/README.md) — hardware quirks (wake from suspend, udev)
