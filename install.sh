#!/usr/bin/env bash

PKG_INSTALL=(
  brightnessctl
  bluetui
  debugedit
  earlyoom
  grim
  hyprland
  impala
  kitty
  kooha
  light
  libreoffice-still
  mpv
  nemo
  nemo-audio-tab
  nemo-fileroller
  nemo-preview
  nemo-python
  neovim
  npm
  nvm
  nwg-displays
  nwg-look
  papirus-folders-catppuccin-git
  qalculate-gtk
  pipewire
  pipewire-pulse
  ripgrep
  xdg-desktop-portal-wlr
  slurp
  hyprpaper
  hyprlock
  hyprtoolkit
  hyprlauncher
  hyprpolkitagent
  hyprshutdown
  hypridle
  ttf-jetbrains-mono-nerd
  stow
  swappy
  docker
  wget
  waybar
  mako
  noisetorch-bin
  lazygit
  lazydocker
  hyprpicker
  hyprsunset
  kdeconnect
  keyd
  wl-clipboard
  zsh-completions
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
)

PKG_AUR_INSTALL=(
  aur/brave-bin
  aur/zsh-theme-powerlevel10k-bin-git
  aur/zsh-auto-venv-git
  aur/visual-studio-code-bin
  aur/wlctl-bin
  aur/pinta
  aur/valent
)

PKG_UNINSTALL=(
  archcraft-omz
  archcraft-hooks-zsh
  archcraft-ranger
  archcraft-help
  archcraft-about
  archcraft-vim
  archcraft-openbox
  xfce4-power-manager
  xfce4-notifyd
  xfce4-settings
  xfce4-terminal
  obmenu-generator
  obconf
  openbox
  plank
  rofi
  wofi
  xcolor
  alacritty
  ranger
  tint2
  mplayer
  mpd
  vim
  simplescreenrecorder
  picom
  meld
  arandr
  xarchiver
  nitrogen
  nm-connection-editor
  networkmanager-dmenu-git
  galculator
  atril
  firefox
  thunar-volman
  thunar-media-tags-plugin
  thunar-archive-plugin
  thunar
)

echo "Installing keyring..."
sudo pacman -Sy --needed --noconfirm archlinux-keyring

echo "Installing yay dependencies..."
sudo pacman -S --needed --noconfirm git base-devel

echo "Cloning and installing yay..."
if [[ ! -d yay ]]; then
  git clone https://aur.archlinux.org/yay.git
fi

pushd yay >/dev/null
makepkg -si --noconfirm
popd >/dev/null

echo "Removing yay directory..."
rm -rf yay

echo "Installing packages..."
yay -Syu --needed --noconfirm --removemake "${PKG_INSTALL[@]}"

echo "Installing AUR packages..."
yay -Syu --needed --noconfirm --removemake "${PKG_AUR_INSTALL[@]}"

echo "Setting up papirus-folders..."
papirus-folders -C cat-mocha-red --theme Papirus-Dark

echo "Setting up user input permissions..."
sudo usermod -a -G input "$USER"

echo "Stowing dotfiles..."
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pushd "$DOTFILES_DIR" >/dev/null
stow .
popd >/dev/null

echo "Uninstalling packages one by one..."
for package in "${PKG_UNINSTALL[@]}"; do
  yay -Rns "$package" --noconfirm
done
