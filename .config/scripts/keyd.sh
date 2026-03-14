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
    printf '{"alt":"active","class":"active","tooltip":"keyd: running"}\n'
  else
    printf '{"alt":"inactive","class":"inactive","tooltip":"keyd: stopped"}\n'
  fi
}

toggle() {
  if is_active; then
    systemctl stop keyd.service && ${notify_cmd} "keyd stopped"
  else
    systemctl start keyd.service && ${notify_cmd} "keyd started"
  fi
}

case "${1:-}" in
  --toggle) toggle ;;
  --start)  systemctl start keyd.service && ${notify_cmd} "keyd started" ;;
  --stop)   systemctl stop  keyd.service && ${notify_cmd} "keyd stopped" ;;
  --status) emit_json ;;
  *)        emit_json ;;
esac
