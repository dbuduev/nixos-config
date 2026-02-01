#!/usr/bin/env bash
set -euo pipefail

# Post-install verification (run after first boot)

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
echo "=== Backup LUKS headers ==="
echo "Run these commands and store the backups safely (NOT on this drive):"
echo ""
echo "  sudo cryptsetup luksHeaderBackup /dev/nvme0n1p2 --header-backup-file luks-swap-header.bak"
echo "  sudo cryptsetup luksHeaderBackup /dev/nvme0n1p3 --header-backup-file luks-root-header.bak"
