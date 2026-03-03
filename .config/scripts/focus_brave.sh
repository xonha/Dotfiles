#!/usr/bin/env bash

# Focus a Brave profile in a dedicated workspace
# Usage: ./focus_brave.sh "Profile 1" 2

PROFILE="$1"
WORKSPACE="$2"

if [ -z "$PROFILE" ] || [ -z "$WORKSPACE" ]; then
  echo "Usage: $0 <PROFILE_NAME> <WORKSPACE_NUMBER>"
  exit 1
fi

# Function to get any Brave window in a specific workspace
get_brave_in_workspace() {
  local ws=$1
  hyprctl clients -j 2>/dev/null | jq -r ".[] | select(.workspace.id == $ws) | select(.class | test(\"brave\")) | .address" | head -n1
}

# Check if window exists in target workspace
EXISTING=$(get_brave_in_workspace "$WORKSPACE")

if [ -n "$EXISTING" ]; then
  # Focus the existing window
  hyprctl dispatch focuswindow "address:$EXISTING"
  exit 0
fi

# No window in target workspace, launch Brave with the specified profile
brave --profile-directory="$PROFILE" > /dev/null 2>&1 &

# Wait for the window to be created
sleep 1.5

# Get all Brave windows
ALL_BRAVE=$(hyprctl clients -j 2>/dev/null | jq -r '.[] | select(.class | test("brave")) | .address')

# Get the most recently created Brave window (last one)
NEW_WINDOW=$(echo "$ALL_BRAVE" | tail -n1)

if [ -n "$NEW_WINDOW" ]; then
  # Move it to the target workspace
  hyprctl dispatch movetoworkspace "$WORKSPACE,address:$NEW_WINDOW"
  sleep 0.2
  hyprctl dispatch focuswindow "address:$NEW_WINDOW"
else
  hyprctl dispatch movetoworkspace "$WORKSPACE"
fi
