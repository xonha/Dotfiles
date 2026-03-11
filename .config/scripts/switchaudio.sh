#!/usr/bin/env bash

set -euo pipefail

cycle_audio_output() {
  local current_sink next_sink i
  local -a sinks streams

  current_sink="$(pactl get-default-sink)"
  mapfile -t sinks < <(pactl list short sinks | awk '{print $2}')

  if [ "${#sinks[@]}" -lt 2 ]; then
    echo "Not enough sinks to switch"
    exit 1
  fi

  next_sink="${sinks[0]}"
  for i in "${!sinks[@]}"; do
    if [ "${sinks[$i]}" = "$current_sink" ]; then
      next_sink="${sinks[$(( (i + 1) % ${#sinks[@]} ))]}"
      break
    fi
  done

  pactl set-default-sink "$next_sink"

  mapfile -t streams < <(pactl list short sink-inputs | awk '{print $1}')
  for stream in "${streams[@]}"; do
    pactl move-sink-input "$stream" "$next_sink"
  done

  echo "Switched output to: $next_sink"
}

cycle_audio_output
