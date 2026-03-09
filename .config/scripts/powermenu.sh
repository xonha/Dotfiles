#!/bin/bash

options=" Logout\n Restart\n Shutdown"
choice=$(printf '%b\n' "$options" | hyprlauncher --dmenu)

[[ -z "$choice" ]] && exit 0

case "$choice" in
    *Logout*)
        hyprshutdown ;;
    *Restart*)
        hyprshutdown -t 'Restarting...' --post-cmd 'systemctl reboot' ;;
    *Shutdown*)
        hyprshutdown -t 'Shutting down...' --post-cmd 'systemctl poweroff' ;;
    *)
        exit 1 ;;
esac