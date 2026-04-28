#!/bin/sh
# Toggle claudecode right pane for tmux
# - If claudecode pane is visible in current window: hide it
# - If claudecode pane exists in another window: bring it back
# - If no claudecode pane exists: create one

CURRENT_WINDOW="$(tmux display-message -p '#{window_id}')"
CURRENT_PATH="$(tmux display-message -p '#{pane_current_path}')"

# Find a pane running claude across all windows in this session
CLAUDE_PANE="$(tmux list-panes -s -F '#{pane_id} #{pane_current_command} #{window_id}' \
  | grep ' claude ' | head -1)"

if [ -n "$CLAUDE_PANE" ]; then
  PANE_ID="$(echo "$CLAUDE_PANE" | awk '{print $1}')"
  WINDOW_ID="$(echo "$CLAUDE_PANE" | awk '{print $3}')"

  if [ "$WINDOW_ID" = "$CURRENT_WINDOW" ]; then
    # Claudecode is visible in this window — hide it
    tmux break-pane -d -s "$PANE_ID"
  else
    # Claudecode exists but is hidden — bring it back
    tmux join-pane -h -l 40% -s "$PANE_ID"
  fi
else
  # No claudecode pane — create one
  tmux split-window -h -l 40% -c "$CURRENT_PATH" claude
fi
