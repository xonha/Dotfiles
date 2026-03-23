#!/usr/bin/env bash
# Step: Set GRUB timeout to 2 seconds

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SETUP_DIR/lib.sh"

GRUB_CONFIG="/etc/default/grub"

run() {
  header "Configure GRUB timeout"

  if [[ ! -f "$GRUB_CONFIG" ]]; then
    warn "GRUB config not found at $GRUB_CONFIG, skipping."
    return 0
  fi

  info "Setting GRUB_TIMEOUT=2 in $GRUB_CONFIG..."
  sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=2/' "$GRUB_CONFIG"

  info "Regenerating GRUB config..."
  sudo grub-mkconfig -o /boot/grub/grub.cfg

  success "GRUB timeout set to 2 seconds."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  run
fi
