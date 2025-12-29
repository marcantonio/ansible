#!/bin/bash

set -euo pipefail

LOCK_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/first-login.lock"
if [[ -e "$LOCK_FILE" ]]; then
    exit 0
fi

mkdir -p "$(dirname "$LOCK_FILE")"

### User actions

PACKAGES=(
    "1password-beta"
    "1password-cli"
    "alacritty"
    "eza"
    "kdenlive"
    "omarchy-nvim"
    "neovim"
    "obs-studio"
    "obsidian"
    "signal-desktop"
    "spotify"
    "starship"
    "typora"
    "xournalpp"
    "zoxide"
)
for pkg in "${PACKAGES[@]}"; do
    if pacman -Qq "$pkg" >/dev/null 2>&1; then
        echo "Removing: $pkg"
        sudo pacman -Rns --noconfirm "$pkg"
    fi
done

WEB_APPS=(
    "Basecamp"
    #"ChatGPT"
    "Discord"
    "Figma"
    "Fizzy"
    "HEY"
    "GitHub"
    "Google Contacts"
    "Google Messages"
    "Google Photos"
    "WhatsApp"
    "YouTube"
    "X"
    "Zoom"
)
for app in "${WEB_APPS[@]}"; do
    omarchy-webapp-remove "$app"
done

# Emacs detritus
sudo rm -f /usr/share/applications/emacs-mail.desktop
sudo rm -f /usr/share/applications/emacsclient.desktop
sudo rm -f /usr/share/applications/emacsclient-mail.desktop


umask 077
: > "$LOCK_FILE"
