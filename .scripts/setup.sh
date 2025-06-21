#!/usr/bin/env bash

PKG_INSTALL=(
  debugedit
  catppuccin-gtk-theme-mocha
  grim
  guake
  hyprland
  kitty
  stow
  light
  lxappearance
  mpv
  neovim
  npm
  nemo
  nemo-audio-tab
  nemo-fileroller
  nemo-preview
  nemo-python
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
  hyprpicker
  kooha
  xfce-polkit
  wl-clipboard
  python-virtualenv
  zsh-completions
  zsh-autosuggestions
  zsh-syntax-highlighting
  network-manager-applet
  keyd
)

PKG_AUR_INSTALL=(
  aur/stremio
  aur/visual-studio-code-bin
  aur/mailspring-bin
  aur/google-chrome
  aur/wdisplays
  aur/wl-gammarelay-rs
  aur/wlrctl
  aur/youtube-music-bin
  aur/lazydocker-bin
  aur/ferdium-bin
  aur/zsh-theme-powerlevel10k-bin-git
  aur/nvm
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

# echo "Setting up git remotes as SSH..."
# cd /tmp/home && git remote set-url origin git@github.com:xonha/home.git
# cd /tmp/hypr && git remote set-url origin git@github.com:xonha/hypr.git
# cd /tmp/nvim && git remote set-url origin git@github.com:xonha/nvim.git

# echo "Copying configurations..."
# cp -r /tmp/home/. ~/
# cp -r /tmp/hypr /tmp/nvim ~/.config

echo "Cloning Dotfiles"
git clone https://github.com/xonha/Dotfiles
cd /Dotfiles && git remote set-url origin git@github.com:xonha/Dotfiles.git

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

if [ "$(hostname)" = "t440s" ]; then
  sudo cp ~/.keyd.conf /etc/keyd/default.conf
  sudo systemctl enable keyd
  sudo systemctl start keyd
  sudo keyd reload
fi
