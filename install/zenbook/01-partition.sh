#!/usr/bin/env bash
set -euo pipefail

# Partition the disk for NixOS with LUKS encryption
# WARNING: This will destroy all data on /dev/nvme0n1

DISK="/dev/nvme0n1"

echo "=== Partitioning $DISK ==="
echo "This will DESTROY all data on $DISK"
read -p "Type 'yes' to continue: " confirm
[[ "$confirm" == "yes" ]] || exit 1

parted "$DISK" -- mklabel gpt
parted "$DISK" -- mkpart ESP fat32 1MiB 1GiB
parted "$DISK" -- set 1 esp on
parted "$DISK" -- mkpart primary linux-swap 1GiB 33GiB
parted "$DISK" -- mkpart primary 33GiB 100%

echo "=== Partition layout ==="
lsblk "$DISK"
echo ""
echo "Created:"
echo "  ${DISK}p1 — 1 GiB EFI (unencrypted)"
echo "  ${DISK}p2 — 32 GiB for LUKS swap"
echo "  ${DISK}p3 — remainder for LUKS root"
