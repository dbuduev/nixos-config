#!/usr/bin/env bash
set -euo pipefail

# Mount filesystems for installation

echo "=== Mounting filesystems ==="

mount /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
swapon /dev/mapper/cryptswap

echo ""
echo "=== Mount complete ==="
findmnt --real
echo ""
swapon --show
