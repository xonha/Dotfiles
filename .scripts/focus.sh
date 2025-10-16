#!/bin/bash

# Check if application name is provided
if [ -z "$1" ]; then
  echo "No application name provided"
  exit 1
fi

APP_NAME=$1

# Check if focus class is provided
if [ -z "$2" ]; then
  FOCUS_CLASS=$APP_NAME
else
  FOCUS_CLASS=$2
fi

# Check if a window with this class exists
WINDOW_ADDR=$(hyprctl clients -j | jq -r ".[] | select(.class==\"$FOCUS_CLASS\") | .address" | head -n1)

if [ -n "$WINDOW_ADDR" ]; then
  # Focus the existing window
  hyprctl dispatch focuswindow address:$WINDOW_ADDR
else
  # No window found → launch the application
  hyprctl dispatch exec "$APP_NAME"
fi
