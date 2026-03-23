#!/usr/bin/env bash
# Step: Install keyd config

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SETUP_DIR/lib.sh"

run() {
  header "Configure keyd"
  local dotfiles_dir
  dotfiles_dir="$(cd "$SETUP_DIR/.." && pwd)"
  sudo cp "$dotfiles_dir/.keyd.conf" /etc/keyd/default.conf
  success "keyd config installed."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  run
fi
