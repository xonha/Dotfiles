#!/usr/bin/env bash

## Script To Manage Brightness For Archcraft (in Wayland).

iDIR="$HOME/.config/mako/icons"

# Get brightness
get_backlight() {
	LIGHT=$(printf "%.0f\n" "$(light -G)")
	echo "${LIGHT}%"
}

# Get icons
get_icon() {
	backlight="$(get_backlight)"
	current="${backlight%%%}"
	if [[ ("$current" -ge "0") && ("$current" -le "20") ]]; then
		icon="$iDIR"/brightness-20.png
	elif [[ ("$current" -ge "20") && ("$current" -le "40") ]]; then
		icon="$iDIR"/brightness-40.png
	elif [[ ("$current" -ge "40") && ("$current" -le "60") ]]; then
		icon="$iDIR"/brightness-60.png
	elif [[ ("$current" -ge "60") && ("$current" -le "80") ]]; then
		icon="$iDIR"/brightness-80.png
	elif [[ ("$current" -ge "80") && ("$current" -le "100") ]]; then
		icon="$iDIR"/brightness-100.png
	fi
}

# Notify
notify_user() {
	notify-send -h string:x-canonical-private-synchronous:sys-notify-backlight -u low -i "$icon" "Brightness : $(get_backlight)"
}

# Increase brightness
inc_backlight() {
	light -A 5 && get_icon && notify_user
}

# Decrease brightness
dec_backlight() {
	light -U 5 && get_icon && notify_user
}

# Execute accordingly
if [[ "$1" == "--get" ]]; then
	get_backlight
elif [[ "$1" == "--inc" ]]; then
	inc_backlight
elif [[ "$1" == "--dec" ]]; then
	dec_backlight
else
	get_backlight
fi
