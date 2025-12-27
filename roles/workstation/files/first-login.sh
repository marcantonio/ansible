#!/bin/bash

set -euo pipefail

LOCK_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/first-login.lock"
if [[ -e "$LOCK_FILE" ]]; then
  exit 0
fi

mkdir -p "$(dirname "$LOCK_FILE")"

### User actions

# Networking
sudo systemctl start NetworkManager
sudo systemctl enable NetworkManager
sudo systemctl start systemd-resolved
sudo systemctl enable systemd-resolved
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# Setup the battery monitor if we have one
if ls /sys/class/power_supply/BAT* &>/dev/null; then
  powerprofilesctl set balanced || true
  systemctl --user enable --now battery-monitor.timer
else
  powerprofilesctl set performance || true
fi

# Keyring
set_default_keyring

# Elephant
elephant service enable
systemctl --user start elephant.service

umask 077
: > "$LOCK_FILE"

sudo systemctl enable sddm
sudo systemctl start sddm

set_default_keyring() {
    keyring_dir="$HOME/.local/share/keyrings"
    keyring_file="$keyring_dir/Default_keyring.keyring"
    default_file="$keyring_dir/default"

    mkdir -p $keyring_dir

    cat << EOF | tee "$keyring_file"
[keyring]
display-name=Default keyring
ctime=$(date +%s)
mtime=0
lock-on-idle=false
lock-after=false
EOF

    cat << EOF | tee "$default_file"
Default_keyring
EOF

    chmod 700 "$keyring_dir"
    chmod 600 "$keyring_file"
    chmod 644 "$default_file"
}
