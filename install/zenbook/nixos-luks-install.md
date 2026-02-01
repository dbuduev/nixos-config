# NixOS Install with LUKS Encryption — Zenbook S16

## Prerequisites

- USB with minimal NixOS ISO
- Internet connection (Wi-Fi or ethernet)
- Your NixOS flake repo accessible (GitHub, USB, etc.)

## 1. Boot the installer

Boot from USB. On the Zenbook you'll likely need to press **F2** (BIOS) or **Esc** (boot menu) during startup. Disable Secure Boot if it's on.

Once booted, switch to root:

```bash
sudo -i
```

If you need Wi-Fi:

```bash
wpa_cli
> add_network
0
> set_network 0 ssid "SSID"
OK
> set_network 0 psk "PASSWORD"
OK
> set_network 0 key_mgmt WPA-PSK
OK
> enable_network 0
OK
> quit
```

Wait a few seconds, then verify connectivity:

```bash
ping -c 3 nixos.org
```

## 2. Identify the disk

```bash
lsblk
```

Your NVMe drive is almost certainly `/dev/nvme0n1`. Confirm before proceeding. **Everything on it will be destroyed.**

## 3. Partition the disk

```bash
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 1GiB
parted /dev/nvme0n1 -- set 1 esp on
parted /dev/nvme0n1 -- mkpart primary linux-swap 1GiB 33GiB
parted /dev/nvme0n1 -- mkpart primary 33GiB 100%
```

This gives you:
- `/dev/nvme0n1p1` — 1 GiB EFI System Partition (unencrypted, required)
- `/dev/nvme0n1p2` — 32 GiB for LUKS-encrypted swap (enables hibernation)
- `/dev/nvme0n1p3` — remainder for LUKS-encrypted root

## 4. Set up LUKS encryption

Encrypt both swap and root partitions. Use the same passphrase for convenience (you'll be prompted twice at boot otherwise):

```bash
cryptsetup luksFormat --type luks2 /dev/nvme0n1p2
cryptsetup luksFormat --type luks2 /dev/nvme0n1p3
```

You'll be prompted to confirm (`YES` in uppercase) and enter a passphrase for each. Pick a strong one.

Open both encrypted partitions:

```bash
cryptsetup open /dev/nvme0n1p2 cryptswap
cryptsetup open /dev/nvme0n1p3 cryptroot
```

This creates `/dev/mapper/cryptswap` and `/dev/mapper/cryptroot`.

## 5. Format the filesystems

```bash
mkfs.fat -F 32 -n BOOT /dev/nvme0n1p1
mkswap -L swap /dev/mapper/cryptswap
mkfs.ext4 -L nixos /dev/mapper/cryptroot
```

## 6. Mount

```bash
mount /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
swapon /dev/mapper/cryptswap
```

## 7. Generate hardware config

```bash
nixos-generate-config --root /mnt
```

This creates `/mnt/etc/nixos/configuration.nix` and `/mnt/etc/nixos/hardware-configuration.nix`. You only care about the generated `hardware-configuration.nix` — it will contain the correct UUIDs and LUKS device entries.

Inspect it:

```bash
cat /mnt/etc/nixos/hardware-configuration.nix
```

Confirm it includes something like:

```nix
boot.initrd.luks.devices."cryptswap".device = "/dev/disk/by-uuid/<UUID-of-nvme0n1p2>";
boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/<UUID-of-nvme0n1p3>";
swapDevices = [{ device = "/dev/disk/by-label/swap"; }];
```

If it doesn't (rare), you'll need to add it manually. Get the UUIDs with:

```bash
blkid /dev/nvme0n1p2
blkid /dev/nvme0n1p3
```

## 8. Install with your flake

You need your flake repo on the installer. Options:

**Option A — Clone from GitHub:**
```bash
nix-shell -p git
git clone https://github.com/dbuduev/nixos-config.git /mnt/etc/nixos/flake-repo
```

**Option B — Copy from another USB or existing partition.**

Before installing, update your flake config:

1. **Replace `hosts/zenbook/hardware-configuration.nix`** with the content of `/mnt/etc/nixos/hardware-configuration.nix` (new UUIDs, LUKS entry).

2. **Update `hosts/zenbook/configuration.nix`** — uncomment/add the LUKS-related lines. You already have placeholders in your config. The key additions:

```nix
# LUKS — SSD TRIM support (safe with LUKS2)
boot.initrd.luks.devices."cryptswap".allowDiscards = true;
boot.initrd.luks.devices."cryptroot".allowDiscards = true;

# Optional: faster crypto in initrd
boot.initrd.availableKernelModules = [ "aes_x86_64" "cryptd" ];

# Hibernation resume from encrypted swap partition
boot.resumeDevice = "/dev/mapper/cryptswap";
```

(The generated hardware-configuration.nix may already include the correct modules — check before duplicating.)

3. **Swap is already configured.** The 32 GiB encrypted swap partition supports hibernation. The `swapDevices` entry should be auto-generated in hardware-configuration.nix. Optionally, you can also enable zram for additional compressed RAM swap:

```nix
zramSwap = {
  enable = true;
  memoryPercent = 50;
};
```

Now install:

```bash
cd /mnt/etc/nixos/flake-repo  # or wherever your flake is
nixos-install --flake .#zenbook
```

You'll be prompted to set the root password.

## 9. Reboot

```bash
umount -R /mnt
reboot
```

Remove the USB. You should see a LUKS passphrase prompt during boot.

## 10. Post-install

Log in as root, set your user password:

```bash
passwd dennisb
```

Then log in as `dennisb` and verify:

```bash
lsblk  # should show cryptroot
sudo cryptsetup status cryptroot  # confirm LUKS2, cipher, etc.
```

Clone your dotfiles/flake repo to your usual location and rebuild:

```bash
sudo nixos-rebuild switch --flake .#zenbook
```

## Notes

- **Secure Boot**: If you want Secure Boot with LUKS, that's a significantly more complex setup (lanzaboote). Not covered here.
- **Plymouth** (`boot.plymouth.enable = true`): Gives a graphical passphrase prompt instead of the plain text one. Optional, cosmetic.
- **LUKS key file or TPM unlock**: Possible but adds complexity. The passphrase-only approach is the simplest and most portable.
- **Backup your LUKS header**: After install, run `sudo cryptsetup luksHeaderBackup /dev/nvme0n1p2 --header-backup-file luks-header.bak` and store it somewhere safe (not on the encrypted drive). If the header gets corrupted, your data is gone.
