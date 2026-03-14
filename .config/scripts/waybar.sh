#!/usr/bin/env bash

trap "killall waybar" EXIT

while true; do
  waybar --bar main-bar --log-level error --config "$HOME/.config/waybar/config.jsonc" --style "$HOME/.config/waybar/style.css" &
  inotifywait -e create,modify "$HOME/.config/waybar"
  killall waybar
done
