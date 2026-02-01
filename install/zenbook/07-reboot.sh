#!/usr/bin/env bash
set -euo pipefail

# Unmount and reboot

echo "=== Unmounting filesystems ==="
swapoff /dev/mapper/cryptswap 2>/dev/null || true
umount -R /mnt

echo ""
echo "Remove the USB drive, then press Enter to reboot..."
read -r

reboot
