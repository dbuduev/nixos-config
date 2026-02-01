#!/usr/bin/env bash
set -euo pipefail

# Format the filesystems

echo "=== Formatting filesystems ==="

echo "Formatting EFI partition..."
mkfs.fat -F 32 -n BOOT /dev/nvme0n1p1

echo "Formatting swap..."
mkswap -L swap /dev/mapper/cryptswap

echo "Formatting root..."
mkfs.ext4 -L nixos /dev/mapper/cryptroot

echo ""
echo "=== Formatting complete ==="
lsblk -f /dev/nvme0n1
