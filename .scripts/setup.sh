#!/usr/bin/env bash

PKG_INSTALL=(
  debugedit
  catppuccin-gtk-theme-mocha
  earlyoom
  gimp
  grim
  guake
  hyprland
  kitty
  stow
  light
  libreoffice-still
  mpv
  nemo
  nemo-audio-tab
  nemo-fileroller
  nemo-preview
  nemo-python
  neovim
  network-manager-applet
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
  ttf-jetbrains-mono-nerd
  swappy
  docker
  wofi
  wget
  waybar
  mako
  noisetorch-bin
  lazygit
  lazydocker
  hyprpicker
  kdeconnect
  keyd
  kooha
  xfce-polkit
  wl-clipboard
  zsh-completions
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
)

PKG_AUR_INSTALL=(
  aur/brave-bin
  aur/google-chrome
  aur/zsh-theme-powerlevel10k-bin-git
  aur/visual-studio-code-bin
  aur/wlrctl
  aur/wdisplays
  aur/wl-gammarelay-rs
)

PKG_UNINSTALL=(
  archcraft-neofetch
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
  galculator
  atril
  firefox
  networkmanager-dmenu-git
  thunar-volman
  thunar-media-tags-plugin
  thunar-archive-plugin
  thunar
)

echo "Repo Dotfiles to SSH"
git remote set-url origin git@github.com:xonha/Dotfile.git

echo "Installing keyring..."
sudo pacman -Sy --needed --noconfirm archlinux-keyring

echo "Installing packages..."
yay -Syu --needed --noconfirm --removemake "${PKG_INSTALL[@]}"

echo "Installing AUR packages..."
yay -Syu --needed --noconfirm --removemake "${PKG_AUR_INSTALL[@]}"

echo "Setting up papirus-folders..."
papirus-folders -C cat-mocha-red --theme Papirus-Dark

echo "Setting up user input permissions..."
sudo usermod -a -G input "$USER"

echo "Uninstalling packages one by one..."
for package in "${PKG_UNINSTALL[@]}"; do
  yay -Rns "$package" --noconfirm
done

if [ "$(hostname)" = "T440s" ]; then
  sudo cp ~/.keyd.conf /etc/keyd/default.conf
  sudo systemctl enable keyd
  sudo systemctl start keyd
  sudo keyd reload
fi
