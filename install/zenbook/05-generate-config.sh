#!/usr/bin/env bash
set -euo pipefail

# Generate NixOS hardware configuration

echo "=== Generating hardware configuration ==="
nixos-generate-config --root /mnt

echo ""
echo "=== Generated hardware-configuration.nix ==="
cat /mnt/etc/nixos/hardware-configuration.nix

echo ""
echo "=== Verifying LUKS entries ==="
HWCONFIG="/mnt/etc/nixos/hardware-configuration.nix"
MISSING=0

if grep -q 'luks.devices."cryptswap"' "$HWCONFIG"; then
    echo "OK: cryptswap entry found"
else
    echo "MISSING: cryptswap entry"
    MISSING=1
fi

if grep -q 'luks.devices."cryptroot"' "$HWCONFIG"; then
    echo "OK: cryptroot entry found"
else
    echo "MISSING: cryptroot entry"
    MISSING=1
fi

if grep -q 'swapDevices' "$HWCONFIG"; then
    echo "OK: swapDevices entry found"
else
    echo "MISSING: swapDevices entry"
    MISSING=1
fi

if [[ $MISSING -eq 1 ]]; then
    echo ""
    echo "Some entries are missing. Get UUIDs with:"
    echo "  blkid /dev/nvme0n1p2"
    echo "  blkid /dev/nvme0n1p3"
    exit 1
fi
