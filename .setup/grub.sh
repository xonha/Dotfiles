#!/usr/bin/env bash
# Step: Configure GRUB timeout

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SETUP_DIR/lib.sh"

GRUB_CONFIG="/etc/default/grub"

run() {
  header "Configure GRUB timeout"

  if [[ ! -f "$GRUB_CONFIG" ]]; then
    warn "GRUB config not found at $GRUB_CONFIG, skipping."
    return 0
  fi

  local choice
  while true; do
    printf "  Enter timeout in seconds (0-10) [0]: "
    read -r choice
    choice="${choice:-0}"

    if [[ "$choice" == "0" ]]; then
      info "Setting GRUB to hidden (GRUB_TIMEOUT=0, GRUB_TIMEOUT_STYLE=hidden)..."
      sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' "$GRUB_CONFIG"
      if grep -q '^GRUB_TIMEOUT_STYLE=' "$GRUB_CONFIG"; then
        sudo sed -i 's/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=hidden/' "$GRUB_CONFIG"
      else
        sudo sed -i '/^GRUB_TIMEOUT=/a GRUB_TIMEOUT_STYLE=hidden' "$GRUB_CONFIG"
      fi
      break
    elif [[ "$choice" =~ ^([1-9]|10)$ ]]; then
      info "Setting GRUB_TIMEOUT=$choice..."
      sudo sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=$choice/" "$GRUB_CONFIG"
      if grep -q '^GRUB_TIMEOUT_STYLE=' "$GRUB_CONFIG"; then
        sudo sed -i 's/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=menu/' "$GRUB_CONFIG"
      fi
      break
    else
      warn "Invalid input. Please enter a number between 0 and 10."
    fi
  done

  info "Regenerating GRUB config..."
  sudo grub-mkconfig -o /boot/grub/grub.cfg

  success "GRUB configured."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  run
fi
