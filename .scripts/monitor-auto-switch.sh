#!/usr/bin/env bash

LAPTOP_MONITOR="eDP-1"
LAPTOP_CONFIG="preferred,auto,1"
CHECK_INTERVAL_SECONDS=3

apply_layout() {
  local monitor
  local external_count=0

  while read -r monitor; do
    [[ -z "$monitor" ]] && continue

    if [[ "$monitor" != "$LAPTOP_MONITOR" ]]; then
      ((external_count++))
    fi
  done < <(hyprctl monitors 2>/dev/null | awk '/^Monitor / {print $2}')

  if ((external_count > 0)); then
    hyprctl keyword monitor "$LAPTOP_MONITOR,disable" >/dev/null 2>&1
  else
    hyprctl keyword monitor "$LAPTOP_MONITOR,$LAPTOP_CONFIG" >/dev/null 2>&1
  fi
}

while true; do
  apply_layout
  sleep "$CHECK_INTERVAL_SECONDS"
done
