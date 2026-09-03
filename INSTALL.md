# Installation Guide

> **One-page reference for installing this NixOS configuration from the minimal
> installer ISO.**
>
> Run everything on the **NixOS minimal installer** (live ISO), not from an
> already-installed system. No `make` is required.

## Wi-Fi (if needed)

If the installer booted with a wired connection, you are probably already online.
If not, connect to Wi-Fi with the NetworkManager TUI included on the minimal
installer:

```bash
nmtui
```

Choose **Activate a connection**, select your SSID, enter the password, and
quit back to the shell. Verify with:

```bash
ping -c 1 github.com
```

## Quick start (interactive script)

```bash
curl -L https://raw.githubusercontent.com/sam/nixos-config/main/install.sh | bash
```

The script will:
1. Install `git` if it's missing (live ISO usually has it).
2. Clone this repo (or use the current directory).
3. Show available disks and ask which one to target.
4. Warn you that **all data on the target disk will be destroyed**.
5. Run `disko-install` — partition, LUKS-encrypt, format, install, and set up
   the bootloader in one step.
6. Prompt to reboot.

You will be asked to set a LUKS password during formatting. This is the same
password you will enter at every boot to unlock the root filesystem.

## Manual steps (if you prefer not to curl-pipe)

```bash
# 1. Connect to Wi-Fi (if not on wired ethernet)
#    Run 'nmtui', pick Activate a connection, enter password, then quit.
#    Verify with: ping -c 1 github.com

# 2. Get the repo
git clone <repo-url>
cd nixos-config

# 3. Find your disk
lsblk

# 4. Install — replace /dev/nvme0n1 with your actual device
sudo nix run github:nix-community/disko/latest#disko-install -- \
  --flake .#hostname --disk main /dev/nvme0n1
```

## What happens to the disk?

**`disko-install` destroys the existing partition table and recreates it from
scratch.** The `destroy` phase is implicit in a fresh install. You do **not**
need to manually clear the disk beforehand (e.g. with `sgdisk -Z` or `wipefs`).

Disk layout created by `modules/disko.nix`:

| Partition | Size | Type | Content |
|---|---|---|---|
| ESP | 512 MiB | EF00 | vfat `/boot` |
| luks | remainder | 8304 (Linux) | LUKS2 container → ext4 `/` |

## Post-install checklist (first boot)

After rebooting into the installed system:

1. **Set your user password** (not stored in this repo):
   ```bash
   passwd
   ```

2. **Connect to Wi-Fi** (NetworkManager is enabled globally):
   ```bash
   nmcli device wifi list
   nmcli device wifi connect "SSID" password "pw"
   ```

3. **Set up GitHub SSH key** (so you can push config changes):
   ```bash
   ssh-keygen -t ed25519 -C "you@example.com"
   cat ~/.ssh/id_ed25519.pub
   ```
   Add the key at GitHub → Settings → SSH and GPG keys → New SSH key.

4. **Switch the remote to SSH**:
   ```bash
   git remote set-url origin git@github.com:<you>/nixos-config.git
   ```

5. **Apply future changes**:
   ```bash
   sudo nixos-rebuild switch --flake .#hostname
   ```

## Troubleshooting

### "I already have partitions and want to re-install"

`disko-install` will overwrite the entire disk. If you want to be extra sure
nothing is mounted:

```bash
sudo umount -R /mnt 2>/dev/null || true
sudo swapoff -a 2>/dev/null || true
```

Then re-run the install command.

### "I want to install without writing EFI boot entries"

By default `disko-install` does **not** write to the machine's NVRAM (good for
portable disks). To make the installed system the default boot option on the
current machine, add `--write-efi-boot-entries`:

```bash
sudo nix run github:nix-community/disko/latest#disko-install -- \
  --write-efi-boot-entries \
  --flake .#hostname --disk main /dev/nvme0n1
```

### "The installer cannot find the flake"

Make sure you are inside the repo directory and `flake.nix` exists. The dot in
`.#hostname` refers to the current directory as the flake root.
