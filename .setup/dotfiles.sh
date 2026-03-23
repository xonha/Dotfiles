#!/usr/bin/env bash
# Step: Stow dotfiles, configure user groups, and switch remote to SSH

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SETUP_DIR/lib.sh"

run() {
  header "Dotfiles & user setup"

  local dotfiles_dir
  dotfiles_dir="$(cd "$SETUP_DIR/.." && pwd)"

  info "Stowing dotfiles from $dotfiles_dir..."
  pushd "$dotfiles_dir" >/dev/null
  stow .
  popd >/dev/null
  success "Dotfiles stowed."

  info "Adding $USER to the 'input' group (needed for keyd / brightness tools)..."
  sudo usermod -a -G input "$USER"
  success "User $USER added to group 'input'."
  warn "Group changes take effect on next login."

  info "Switching git remote to SSH..."
  local current
  current="$(git -C "$dotfiles_dir" remote get-url origin)"

  if [[ "$current" == git@github.com:* ]]; then
    warn "Remote is already SSH: $current"
  elif [[ "$current" != https://github.com/* ]]; then
    error "Unexpected remote URL format: $current"
  else
    local new="${current/https:\/\/github.com\//git@github.com:}"
    git -C "$dotfiles_dir" remote set-url origin "$new"
    success "Remote updated: $current -> $new"
  fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  run
fi
