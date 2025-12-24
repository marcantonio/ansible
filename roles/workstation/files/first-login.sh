#!/bin/bash

set -euo pipefail

LOCK_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/first-login.lock"
if [[ -e "$LOCK_FILE" ]]; then
  exit 0
fi

mkdir -p "$(dirname "$LOCK_FILE")"

### User actions

# Setup the battery monitor if we have one
if ls /sys/class/power_supply/BAT* &>/dev/null; then
  powerprofilesctl set balanced || true
  systemctl --user enable --now battery-monitor.timer
else
  powerprofilesctl set performance || true
fi

# Systemd-resolved
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# Elephant
#elephant service enable
#systemctl --user start elephant.service

umask 077
: > "$LOCK_FILE"
