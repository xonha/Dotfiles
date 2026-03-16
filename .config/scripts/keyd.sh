#!/usr/bin/env bash
# ~/.config/scripts/keyd.sh
# Start/stop keyd.service and emit a Waybar-compatible JSON status.

set -Eeuo pipefail

notify_cmd='notify-send -h string:x-canonical-private-synchronous:sys-notify-keyd -u low'

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
    systemctl stop keyd.service && ${notify_cmd} "Keyd stopped"
  else
    systemctl start keyd.service && ${notify_cmd} "Keyd started"
  fi
}

case "${1:-}" in
--start) systemctl start keyd.service && ${notify_cmd} "Keyd started" ;;
--stop) systemctl stop keyd.service && ${notify_cmd} "Keyd stopped" ;;
--status) emit_json ;;
--toggle) toggle ;;
*) emit_json ;;
esac
