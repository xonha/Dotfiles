#!/usr/bin/env bash
# Step: Uninstall legacy Archcraft / unused packages

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SETUP_DIR/lib.sh"

PKG_UNINSTALL=(
  archcraft-omz
  archcraft-hooks-zsh
  archcraft-ranger
  archcraft-help
  archcraft-about
  archcraft-vim
  archcraft-neofetch
  archcraft-openbox
  xfce4-power-manager
  xfce4-notifyd
  xfce4-settings
  xfce4-terminal
  obmenu-generator
  obconf
  openbox
  plank
  rofi
  xcolor
  alacritty
  ranger
  tint2
  mplayer
  mpd
  vim
  simplescreenrecorder
  picom
  meld
  arandr
  xarchiver
  nitrogen
  nm-connection-editor
  networkmanager-dmenu-git
  galculator
  atril
  firefox
  thunar-volman
  thunar-media-tags-plugin
  thunar-archive-plugin
  thunar
)

run() {
  header "Uninstall legacy packages"

  local removed=0
  local skipped=0

  for pkg in "${PKG_UNINSTALL[@]}"; do
    if yay -Qi "$pkg" &>/dev/null; then
      info "Removing $pkg..."
      if yay -Rns "$pkg" --noconfirm 2>/dev/null; then
        success "Removed $pkg"
        (( removed++ ))
      else
        warn "Could not remove $pkg (may have dependents)"
        (( skipped++ ))
      fi
    else
      info "Not installed, skipping: $pkg"
    fi
  done

  success "Done. Removed: $removed, skipped: $skipped."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  run
fi
