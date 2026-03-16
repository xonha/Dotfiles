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

# Launch mode:
# - current (default): launch on current workspace
# - emptyn: launch on an empty workspace
# - workspace:N: launch on workspace N (e.g. workspace:1)
LAUNCH_MODE=${3:-current}

# When set to 1, always launch a new instance instead of focusing an existing window.
FORCE_LAUNCH=${4:-0}

# Check if a window with this class exists
WINDOW_ADDR=$(hyprctl clients -j | jq -r ".[] | select(.class==\"$FOCUS_CLASS\") | .address" | head -n1)

if [ -n "$WINDOW_ADDR" ] && [ "$FORCE_LAUNCH" != "1" ]; then
  # Focus the existing window
  hyprctl dispatch focuswindow address:$WINDOW_ADDR
else
  # No window found (or force launch) -> launch the application in the desired workspace.
  if [ "$LAUNCH_MODE" = "emptyn" ]; then
    hyprctl dispatch exec "[workspace emptyn] $APP_NAME"
  elif [[ "$LAUNCH_MODE" == workspace:* ]]; then
    WS_NUM="${LAUNCH_MODE#workspace:}"
    hyprctl dispatch exec "[workspace $WS_NUM] $APP_NAME"
  else
    hyprctl dispatch exec "$APP_NAME"
  fi
fi
