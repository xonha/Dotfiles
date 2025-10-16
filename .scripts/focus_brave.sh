#!/usr/bin/env bash

# TAG="ProfileMaisTodos"

# Check if application name is provided
if [ -z "$1" ]; then
  echo "No application name provided"
  exit 1
fi

TAG=$1

# Check if a window with this tag already exists
WINDOW_ADDR=$(
  hyprctl clients -j | jq -r --arg TAG "$TAG" '.[] | select(.tags | index($TAG)) | .address' | head -n1
)

if [ -n "$WINDOW_ADDR" ]; then
  # Focus the existing window
  hyprctl dispatch focuswindow address:$WINDOW_ADDR
  exit 0
else
  brave --disable-features=WaylandWpColorManagerV1 -profile-directory="$TAG"
  sleep 0.3
  hyprctl dispatch tagwindow $TAG
fi
