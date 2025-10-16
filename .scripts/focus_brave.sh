#!/usr/bin/env bash

# Usage:
# ./open_brave_profile.sh "Profile 1" 12

# Check if both arguments are provided
if [ -z "$1" ]; then
  echo "Usage: $0 <PROFILE_NAME> [WORKSPACE]"
  exit 1
fi

TAG="$1"
WORKSPACE="${2:-1}" # Default to workspace 1 if not provided

# Check if a window with this tag already exists
WINDOW_ADDR=$(
  hyprctl clients -j | jq -r --arg TAG "$TAG" '.[] | select(.tags | index($TAG)) | .address' | head -n1
)

if [ -n "$WINDOW_ADDR" ]; then
  # Focus the existing window and move it to the specified workspace
  hyprctl dispatch focuswindow address:$WINDOW_ADDR
  hyprctl dispatch movetoworkspace "$WORKSPACE"
  exit 0
else
  # Launch new Brave window for the given profile
  brave --disable-features=WaylandWpColorManagerV1 -profile-directory="$TAG" &
  sleep 0.4
  hyprctl dispatch tagwindow "$TAG"
  sleep 0.1
  hyprctl dispatch movetoworkspace "$WORKSPACE"
fi
