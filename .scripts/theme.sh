#!/usr/bin/env bash

## Set GTK Themes, Icons, Cursor and Fonts

THEME='Catppuccin-Mocha-Standard-Red-Dark'
ICONS='Papirus-Dark'
FONT='JetBrainsMono Nerd Font Bold 10'
CURSOR='Qogirr-Dark'

SCHEMA='gsettings set org.gnome.desktop.interface'

apply_themes() {
  ${SCHEMA} gtk-theme "$THEME"
  ${SCHEMA} icon-theme "$ICONS"
  ${SCHEMA} cursor-theme "$CURSOR"
  ${SCHEMA} font-name "$FONT"
}

apply_themes
