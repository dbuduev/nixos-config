#!/usr/bin/env bash
set -euo pipefail

# Install NixOS from flake
# Run this after:
# 1. Cloning your flake repo to /mnt/etc/nixos/flake-repo
# 2. Replacing hosts/zenbook/hardware-configuration.nix with generated one
# 3. Uncommenting LUKS options in hosts/zenbook/configuration.nix

FLAKE_DIR="${1:-/mnt/etc/nixos/flake-repo}"

if [[ ! -f "$FLAKE_DIR/flake.nix" ]]; then
    echo "Flake not found. Cloning from GitHub..."
    nix-shell -p git --run "git clone https://github.com/dbuduev/nixos-config.git $FLAKE_DIR"
fi

echo "=== Installing NixOS from $FLAKE_DIR ==="
cd "$FLAKE_DIR"
nixos-install --flake .#zenbook

echo ""
echo "=== Installation complete ==="
echo "You'll be prompted to set the root password."
echo "After reboot, log in as root and run: passwd dennisb"
