#!/usr/bin/env bash
# Interactive setup orchestrator
# Each optional step asks for confirmation before running.
# Safe to run on both a desktop and an SSH-only server.

set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.setup"
source "$SETUP_DIR/lib.sh"

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

printf "${BOLD}${BLUE}"
printf "╔══════════════════════════════════════╗\n"
printf "║         Henrique's Setup Script      ║\n"
printf "╚══════════════════════════════════════╝\n"
printf "${RESET}\n"
printf "Optional steps will ask for confirmation.\n"
printf "Press ${BOLD}Enter${RESET} (or type ${BOLD}y${RESET}) to run, type ${BOLD}n${RESET} to skip.\n"

# ── yay (mandatory) ────────────────────────────────────────────────────────
header "Bootstrap yay"
info "Install the yay AUR helper (requires git + base-devel)."
source "$SETUP_DIR/yay.sh"
run

# ── Dotfiles (optional) ────────────────────────────────────────────────────
if confirm_step \
    "Stow dotfiles & configure user groups" \
    "Run 'stow .' from the dotfiles root and add $USER to the 'input' group."; then
  source "$SETUP_DIR/dotfiles.sh"
  run
fi

# ── Server packages (optional) ────────────────────────────────────────────
if confirm_step \
    "Install server packages" \
    "Headless tools: neovim, docker, lazygit, zsh plugins, tailscale, etc.
  Suitable for both laptop and SSH-only cloud server."; then
  source "$SETUP_DIR/server.sh"
  run
fi

# ── Desktop packages (optional) ───────────────────────────────────────────
if confirm_step \
    "Install desktop packages" \
    "GUI stack: Hyprland, Waybar, Kitty, Brave, VS Code, nemo, pipewire, etc.
  Skip this on headless / SSH-only machines."; then
  source "$SETUP_DIR/desktop.sh"
  run
fi

# ── Uninstall legacy packages (optional) ──────────────────────────────────
if confirm_step \
    "Uninstall legacy packages" \
    "Remove Archcraft defaults and other packages you no longer use."; then
  source "$SETUP_DIR/uninstall.sh"
  run
fi

# ── keyd (mandatory) ──────────────────────────────────────────────────────
header "Configure keyd"
info "Copying keyd config to /etc/keyd/default.conf."
source "$SETUP_DIR/keyd.sh"

# ── Done ───────────────────────────────────────────────────────────────────
printf "\n${BOLD}${GREEN}All selected steps completed.${RESET}\n"
printf "You may need to ${BOLD}log out and back in${RESET} for group changes to take effect.\n\n"
