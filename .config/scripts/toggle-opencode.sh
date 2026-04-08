#!/bin/sh
# Toggle opencode right pane for tmux
# - If opencode pane is visible in current window: hide it
# - If opencode pane exists in another window: bring it back
# - If no opencode pane exists: create one

CURRENT_WINDOW="$(tmux display-message -p '#{window_id}')"
CURRENT_PATH="$(tmux display-message -p '#{pane_current_path}')"

# Find a pane running opencode across all windows in this session
OPENCODE_PANE="$(tmux list-panes -s -F '#{pane_id} #{pane_current_command} #{window_id}' \
  | grep ' opencode ' | head -1)"

if [ -n "$OPENCODE_PANE" ]; then
  PANE_ID="$(echo "$OPENCODE_PANE" | awk '{print $1}')"
  WINDOW_ID="$(echo "$OPENCODE_PANE" | awk '{print $3}')"

  if [ "$WINDOW_ID" = "$CURRENT_WINDOW" ]; then
    # Opencode is visible in this window — hide it
    tmux break-pane -d -s "$PANE_ID"
  else
    # Opencode exists but is hidden — bring it back
    tmux join-pane -h -l 40% -s "$PANE_ID"
  fi
else
  # No opencode pane — create one
  tmux split-window -h -l 40% -c "$CURRENT_PATH" opencode
fi
