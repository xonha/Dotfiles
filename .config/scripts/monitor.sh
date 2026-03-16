#!/usr/bin/env bash
#
# monitor-auto-switch.sh
#
# Watches Hyprland monitor events and copies the right profile into
# monitors.conf, then reloads Hyprland.
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

apply_layout() {
    local connected
    connected=$(hyprctl monitors all -j 2>/dev/null)

    local has_desk_1=false has_desk_2=false has_travel=false

    echo "$connected" | grep -qF "$MONITOR_DESC_DESK_1" && has_desk_1=true
    echo "$connected" | grep -qF "$MONITOR_DESC_DESK_2" && has_desk_2=true
    [[ -n "$MONITOR_DESC_TRAVEL" ]] && echo "$connected" | grep -qF "$MONITOR_DESC_TRAVEL" && has_travel=true

    local profile
    if $has_desk_1 && $has_desk_2; then
        profile="monitors-docked.conf"
    elif $has_travel; then
        profile="monitors-travel.conf"
    else
        profile="monitors-default.conf"
    fi

    local source="$HYPR_CONFIG_DIR/$profile"

    if diff -q "$source" "$MONITORS_CONF" >/dev/null 2>&1; then
        return  # already active, nothing to do
    fi

    cp "$source" "$MONITORS_CONF"
    hyprctl reload >/dev/null 2>&1
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
