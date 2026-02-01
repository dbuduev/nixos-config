#!/usr/bin/env bash
set -euo pipefail

# Post-install verification and setup (run after first boot as dennisb)

INSTALL_REPO="/etc/nixos/flake-repo"
TARGET_REPO="/home/dennisb/nixos-config"

echo "=== Post-install verification ==="

echo ""
echo "--- Block devices ---"
lsblk

echo ""
echo "--- LUKS status ---"
sudo cryptsetup status cryptroot

echo ""
echo "--- Swap status ---"
swapon --show

echo ""
echo "=== Moving flake repo ==="
if [[ -d "$INSTALL_REPO" ]]; then
    sudo mv "$INSTALL_REPO" "$TARGET_REPO"
    sudo chown -R dennisb:users "$TARGET_REPO"
    echo "Moved to: $TARGET_REPO"
else
    echo "Repo already at $TARGET_REPO or not found at $INSTALL_REPO"
fi

echo ""
echo "=== Committing hardware-configuration.nix ==="
cd "$TARGET_REPO"
git add hosts/zenbook/hardware-configuration.nix hosts/zenbook/configuration.nix
git commit -m "zenbook: LUKS encryption with swap partition"
echo "Committed. Push when ready: git push"

echo ""
echo "=== Backup LUKS headers ==="
echo "Run these commands and store the backups safely (NOT on this drive):"
echo ""
echo "  sudo cryptsetup luksHeaderBackup /dev/nvme0n1p2 --header-backup-file luks-swap-header.bak"
echo "  sudo cryptsetup luksHeaderBackup /dev/nvme0n1p3 --header-backup-file luks-root-header.bak"
