#!/usr/bin/env bash
## Toggle mic noise suppression (RNNoise via PipeWire filter-chain).
##   denoise.sh [toggle|on|off]   (default: toggle)
## Switches the default source between the RNNoise virtual mic and the raw
## Bluetooth headset mic. The filter-chain itself is always loaded by PipeWire
## (see ~/.config/pipewire/pipewire.conf.d/99-rnnoise.conf).

RNNOISE="effect_output.rnnoise"
RAW="bluez_input.00:02:5B:00:FF:0E"
notify='notify-send -h string:x-canonical-private-synchronous:denoise -u low'
action="${1:-toggle}"

[ "$action" = "toggle" ] && {
  [ "$(pactl get-default-source)" = "$RNNOISE" ] && action="off" || action="on"
}

case "$action" in
  on)  pactl set-default-source "$RNNOISE" && $notify "Supressao de ruido: ON" ;;
  off) pactl set-default-source "$RAW"     && $notify "Supressao de ruido: OFF" ;;
  *)   echo "uso: $0 [toggle|on|off]" >&2; exit 1 ;;
esac
