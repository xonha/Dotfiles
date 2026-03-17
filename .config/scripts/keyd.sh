#!/usr/bin/env bash
# ~/.config/scripts/keyd.sh
# Start/stop keyd.service and emit a Waybar-compatible JSON status.

set -Eeuo pipefail

is_active() {
  systemctl is-active --quiet keyd.service
}

emit_json() {
  if is_active; then
    printf '{"text":"󰌌 Keyd","alt":"active","class":"active","tooltip":"Keyd: running"}\n'
  else
    printf '{"text":"","alt":"inactive","class":"inactive","tooltip":"Keyd: stopped"}\n'
  fi
}

toggle() {
  if is_active; then
    systemctl stop keyd.service
  else
    systemctl start keyd.service
  fi
}

case "${1:-}" in
--start) systemctl start keyd.service ;;
--stop) systemctl stop keyd.service ;;
--status) emit_json ;;
--toggle) toggle ;;
*) emit_json ;;
esac
