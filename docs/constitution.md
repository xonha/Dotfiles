# Constitution

The principles this dotfiles project is built on.

## Purpose

Three goals, equal weight:

1. **Fast reinstall.** A fresh machine should reach a fully productive state in one session.
   Clone the repo, run `.install.sh`, done.

2. **Config as code.** Every preference, keybind, and tool config lives here.
   Nothing important exists only on disk. If it matters, it's committed.

3. **Multi-machine consistency.** Same tools, same muscle memory, same feel —
   whether on the laptop, inside devbox, or on the work machine.

## Philosophy

**Bash only. No magic.**

- Plain shell scripts over Ansible, Nix, Chezmoi, or any framework.
- If a future reader can't understand a script in 30 seconds, it's too complex.
- `yay` for packages. `stow` for dotfiles. Systemd for services. Nothing else.

**Laptop is primary.**

- The ThinkPad running Arch + Hyprland is the main machine.
- Bazzite and WSL are supported but secondary — they don't drive design decisions.

**Explicit over implicit.**

- Setup steps are visible in scripts, not hidden in tool behavior.
- Machine-specific config (monitors, hardware quirks) is gitignored and documented — not templated.

**Docs are part of the repo.**

- If a setup step requires copy-pasting from memory, it's a bug.
- Runbooks, gotchas, and infra details live in `docs/`.

## Hard Rules

**Never commit secrets. This repo is public.**

- No API keys, tokens, passwords, or credentials — ever.
- Config files that require secrets must use environment variables or external secret stores (e.g. `~/.env`, a password manager, or a gitignored file).
- If a tool config needs a token to function, document *where* to put it — not the token itself.
- Gitignore any file that could contain secrets before touching it.
- If a secret is accidentally committed: rotate it immediately, then purge from git history.

## What this repo is NOT

- Not a framework for others to fork. Opinionated for one person's workflow.
- Not a Nix flake or declarative system. Bash + stow is enough.
- Not comprehensive coverage of the work machine — Windows/WSL is best-effort.
