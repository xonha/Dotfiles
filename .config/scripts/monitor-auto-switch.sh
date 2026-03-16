#!/usr/bin/env bash
#
# monitor-auto-switch.sh
#
# Watches Hyprland monitor events, selects the right profile, applies each
# monitor= directive live via `hyprctl keyword`, and writes the active lines
# into monitors.conf so the layout persists across restarts.
#
# Profiles (all live in $HYPR_CONFIG_DIR):
#   monitors-docked.conf  – both external desk monitors connected
#   monitors-travel.conf  – one portable external + laptop display
#   monitors-default.conf – laptop display only
#
# Relies on `socat` to listen on the Hyprland IPC event socket.

HYPR_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
MONITORS_CONF="$HYPR_CONFIG_DIR/monitors.conf"

# Descriptions that identify the two desk external monitors.
MONITOR_DESC_DESK_1="SUE SFP2412FHD 000000000000"
MONITOR_DESC_DESK_2="Shenzhen KTC Technology Group SFPCCB24180 000000000000"

# Description for the portable travel monitor.
# TODO: fill in once the monitor is connected and identified via `hyprctl monitors all`.
MONITOR_DESC_TRAVEL=""

# ---------------------------------------------------------------------------

select_profile() {
    local connected
    connected=$(hyprctl monitors all -j 2>/dev/null)

    local has_desk_1=false has_desk_2=false has_travel=false

    echo "$connected" | grep -qF "$MONITOR_DESC_DESK_1" && has_desk_1=true
    echo "$connected" | grep -qF "$MONITOR_DESC_DESK_2" && has_desk_2=true
    [[ -n "$MONITOR_DESC_TRAVEL" ]] && echo "$connected" | grep -qF "$MONITOR_DESC_TRAVEL" && has_travel=true

    if $has_desk_1 && $has_desk_2; then
        echo "monitors-docked.conf"
    elif $has_travel; then
        echo "monitors-travel.conf"
    else
        echo "monitors-default.conf"
    fi
}

apply_layout() {
    local profile
    profile=$(select_profile)
    local source="$HYPR_CONFIG_DIR/$profile"

    # Extract only the monitor= lines from the profile (skip comments/blanks).
    local lines
    mapfile -t lines < <(grep -E '^[[:space:]]*monitor[[:space:]]*=' "$source")

    if [[ ${#lines[@]} -eq 0 ]]; then
        return  # profile has no monitor directives yet (e.g. travel placeholder)
    fi

    # Skip if monitors.conf already contains exactly these lines.
    local current_lines
    mapfile -t current_lines < <(grep -E '^[[:space:]]*monitor[[:space:]]*=' "$MONITORS_CONF" 2>/dev/null)

    if [[ "${lines[*]}" == "${current_lines[*]}" ]]; then
        return  # already active, nothing to do
    fi

    # Apply each directive live so the change takes effect immediately.
    for line in "${lines[@]}"; do
        # Strip leading whitespace and the "monitor=" prefix, leaving just the value.
        local value="${line#*=}"
        hyprctl keyword monitor "$value" >/dev/null 2>&1
    done

    # Persist the active directives into monitors.conf.
    printf '%s\n' "${lines[@]}" > "$MONITORS_CONF"
}

# Run once at startup to handle current state before any events arrive.
apply_layout

# React to every monitor connect/disconnect event in real time.
SOCKET="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

socat -U - "UNIX-CONNECT:$SOCKET" 2>/dev/null | while IFS= read -r line; do
    case "$line" in
        monitoradded*|monitorremoved*)
            apply_layout
            ;;
    esac
done
