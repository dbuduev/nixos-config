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

Script: [`00-wifi.sh`](00-wifi.sh)

```bash
./00-wifi.sh "SSID" "PASSWORD"
```

Or manually:

```bash
wpa_cli -i wlan0 add_network
wpa_cli -i wlan0 set_network 0 ssid '"SSID"'
wpa_cli -i wlan0 set_network 0 psk '"PASSWORD"'
wpa_cli -i wlan0 set_network 0 key_mgmt WPA-PSK
wpa_cli -i wlan0 enable_network 0
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

Script: [`01-partition.sh`](01-partition.sh)

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

Script: [`02-luks.sh`](02-luks.sh)

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

Script: [`03-format.sh`](03-format.sh)

```bash
mkfs.fat -F 32 -n BOOT /dev/nvme0n1p1
mkswap -L swap /dev/mapper/cryptswap
mkfs.ext4 -L nixos /dev/mapper/cryptroot
```

## 6. Mount

Script: [`04-mount.sh`](04-mount.sh)

```bash
mount /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
swapon /dev/mapper/cryptswap
```

## 7. Generate hardware config

Script: [`05-generate-config.sh`](05-generate-config.sh)

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

Script: [`06-install.sh`](06-install.sh)

The install script will:
1. Clone the flake repo from GitHub (if not present)
2. Copy the generated `hardware-configuration.nix` to the repo
3. Prompt you to edit `configuration.nix`
4. Run `nixos-install`

Before proceeding, you'll need to uncomment the LUKS options in `hosts/zenbook/configuration.nix`:

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

The swap partition is already configured. The `swapDevices` entry is auto-generated in hardware-configuration.nix.

Now run the install script:

```bash
./06-install.sh
```

You'll be prompted to edit configuration.nix, then to set the root password.

## 9. Reboot

Script: [`07-reboot.sh`](07-reboot.sh)

```bash
umount -R /mnt
reboot
```

Remove the USB. You should see a LUKS passphrase prompt during boot.

## 10. Post-install

Script: [`08-post-install.sh`](08-post-install.sh)

Log in as root, set your user password:

```bash
passwd dennisb
```

Then log in as `dennisb` and run the post-install script:

```bash
./08-post-install.sh
```

This will:
- Verify LUKS and swap are working
- Move flake repo to `/home/dennisb/nixos-config`
- Commit the hardware-configuration.nix changes

Then rebuild to verify:

```bash
cd ~/nixos-config
sudo nixos-rebuild switch --flake .#zenbook
```

## Notes

- **Secure Boot**: If you want Secure Boot with LUKS, that's a significantly more complex setup (lanzaboote). Not covered here.
- **Plymouth** (`boot.plymouth.enable = true`): Gives a graphical passphrase prompt instead of the plain text one. Optional, cosmetic.
- **LUKS key file or TPM unlock**: Possible but adds complexity. The passphrase-only approach is the simplest and most portable.
- **Backup your LUKS header**: After install, run `sudo cryptsetup luksHeaderBackup /dev/nvme0n1p2 --header-backup-file luks-header.bak` and store it somewhere safe (not on the encrypted drive). If the header gets corrupted, your data is gone.
