#!/usr/bin/env bash
# ~/.config/scripts/dock-handler.sh
# Unified dock handler: monitors display + toggles keyd
# Listens to udev for USB device changes

set -Eeuo pipefail

KEYD_SERVICE="keyd.service"

apply_dock() {
    echo "Applying docked configuration..."
    hyprctl keyword monitor "eDP-1, disable"
    hyprctl keyword monitor "desc:Shenzhen KTC Technology Group SFPCCB24180 000000000000,1920x1080@120.00000,0x0,1.00000000,transform,0,vrr,0"
    hyprctl keyword monitor "desc:SUE SFP2412FHD 000000000000,1920x1080@120.00000,1920x0,1.00000000,transform,0,vrr,0"
    systemctl stop "$KEYD_SERVICE"
}

apply_travel() {
    echo "Applying travel configuration..."
    hyprctl keyword monitor "eDP-1,1920x1080@60.02,192x2160,1.0"
    hyprctl keyword monitor "desc:Invalid Vendor Codename - RTK 0x1920 demoset-1,1920x1080@60.0,192x1080,1.0"
    systemctl start "$KEYD_SERVICE"
}

apply_default() {
    echo "Applying default configuration..."
    hyprctl keyword monitor "eDP-1,1920x1080@60.02000,0x0,1.00000000,transform,0,vrr,0"
    systemctl start "$KEYD_SERVICE"
}

DOCK_ID="04b4:f649"

check_dock() {
    if lsusb | grep -q "$DOCK_ID"; then
        return 0
    else
        return 1
    fi
}

apply() {
    if check_dock; then
        apply_dock
    else
        apply_travel
    fi
}

case "${1:-}" in
--apply) apply ;;
--dock) apply_dock ;;
--travel) apply_travel ;;
--default) apply_default ;;
*)
    echo "Listening for dock USB events (04b4:f649)..."
    udevadm monitor --subsystem-match=usb --property 2>/dev/null | while read -r line; do
        if echo "$line" | grep -q "04b4"; then
            echo "Dock device change detected, checking dock state..."
            sleep 2
            apply
        fi
    done
    ;;
esac