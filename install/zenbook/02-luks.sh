#!/usr/bin/env bash
set -euo pipefail

# Set up LUKS encryption on swap and root partitions
# Use the same passphrase for both to get single prompt at boot

SWAP_PART="/dev/nvme0n1p2"
ROOT_PART="/dev/nvme0n1p3"

echo "=== Setting up LUKS encryption ==="
echo "You'll be prompted for a passphrase for each partition."
echo "Use the SAME passphrase for both to avoid double prompts at boot."
echo ""

echo "--- Encrypting swap partition ($SWAP_PART) ---"
cryptsetup luksFormat --type luks2 "$SWAP_PART"

echo ""
echo "--- Encrypting root partition ($ROOT_PART) ---"
cryptsetup luksFormat --type luks2 "$ROOT_PART"

echo ""
echo "--- Opening encrypted partitions ---"
cryptsetup open "$SWAP_PART" cryptswap
cryptsetup open "$ROOT_PART" cryptroot

echo ""
echo "=== LUKS setup complete ==="
echo "Created: /dev/mapper/cryptswap"
echo "Created: /dev/mapper/cryptroot"
