# Catppuccin-Black Theme

A custom dark GTK theme based on Catppuccin Mocha with a pure black color palette.

## Color Palette

This theme uses the following custom color scheme:

| Name     | Hex       | Usage                              |
| -------- | --------- | ---------------------------------- |
| Base     | `#141414` | Main background color              |
| Mantle   | `#171717` | Slightly lighter background        |
| Crust    | `#101010` | Darker background (e.g., tab bars) |
| Surface0 | `#1f1f1f` | Surface color                      |
| Surface1 | `#262626` | Elevated surface                   |
| Surface2 | `#2e2e2e` | More elevated surface              |
| Overlay0 | `#444444` | Overlay/border color               |
| Overlay1 | `#545454` | Lighter overlay                    |
| Overlay2 | `#646464` | Even lighter overlay               |
| Subtext0 | `#949494` | Subtle text                        |
| Subtext1 | `#ababab` | Less subtle text                   |
| Text     | `#d0d0d0` | Primary text color                 |

## Installation with GNU Stow

This theme is designed to work with GNU Stow for easy dotfile management.

### Using Stow

From your Dotfiles directory:

```bash
stow .
```

This will create a symlink from `~/.themes/Catppuccin-Black` to this theme directory.

### Manual Installation

If you prefer not to use Stow:

```bash
cp -r ~/.dotfiles/.themes/Catppuccin-Black ~/.themes/
```

## Applying the Theme

### GTK3/GTK4

Use your desktop environment's theme settings or a tool like `lxappearance`:

```bash
lxappearance
```

Then select "Catppuccin-Black" from the theme list.

### GNOME/GTK

You can also set it via gsettings:

```bash
gsettings set org.gnome.desktop.interface gtk-theme "Catppuccin-Black"
gsettings set org.gnome.desktop.wm.preferences theme "Catppuccin-Black"
```

### XFCE

```bash
xfconf-query -c xsettings -p /Net/ThemeName -s "Catppuccin-Black"
xfconf-query -c xfwm4 -p /general/theme -s "Catppuccin-Black"
```

## Supported Desktop Environments

- GTK3 applications
- GTK4 applications
- GNOME Shell
- Cinnamon
- XFCE (XFWM4)
- Metacity

## Based On

This theme is derived from [Catppuccin GTK](https://github.com/catppuccin/gtk) - Catppuccin Mocha Standard Red Dark variant.

## License

This theme inherits the license from the original Catppuccin GTK theme.
