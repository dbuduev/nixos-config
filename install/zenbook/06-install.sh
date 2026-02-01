#!/usr/bin/env bash
set -euo pipefail

# Install NixOS from flake

FLAKE_DIR="${1:-/mnt/etc/nixos/flake-repo}"
GENERATED="/mnt/etc/nixos/hardware-configuration.nix"
TARGET="$FLAKE_DIR/hosts/zenbook/hardware-configuration.nix"

# Clone if needed
if [[ ! -f "$FLAKE_DIR/flake.nix" ]]; then
    echo "=== Cloning flake repo ==="
    nix-shell -p git --run "git clone https://github.com/dbuduev/nixos-config.git $FLAKE_DIR"
fi

# Copy hardware config
echo ""
echo "=== Copying hardware-configuration.nix ==="
cp "$GENERATED" "$TARGET"
echo "Copied to: $TARGET"

# Prompt to edit configuration.nix
echo ""
echo "=== IMPORTANT: Edit configuration.nix ==="
echo "Uncomment the LUKS options in: $FLAKE_DIR/hosts/zenbook/configuration.nix"
echo ""
echo "  boot.initrd.luks.devices.\"cryptswap\".allowDiscards = true;"
echo "  boot.initrd.luks.devices.\"cryptroot\".allowDiscards = true;"
echo "  boot.resumeDevice = \"/dev/mapper/cryptswap\";"
echo ""
read -p "Press Enter after editing (or Ctrl+C to abort)..."

# Stage changes so flake can see them (flakes only see git-tracked files)
echo ""
echo "=== Staging changes for flake ==="
cd "$FLAKE_DIR"
nix-shell -p git --run "git add -A"

# Install
echo ""
echo "=== Installing NixOS from $FLAKE_DIR ==="
nixos-install --flake .#zenbook

echo ""
echo "=== Installation complete ==="
echo "After reboot, log in as root and run: passwd dennisb"
