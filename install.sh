#!/usr/bin/env bash
# install.sh
#
# One-shot installer for this NixOS configuration.
# Run from the NixOS minimal installer (live ISO) as root.
#
# Usage:
#   curl -L <raw-url> | bash
#   # or, after cloning the repo:
#   bash install.sh
#
# This script partitions the target disk, creates a LUKS-encrypted root
# filesystem, installs the NixOS closure, and sets up the bootloader.
# ALL EXISTING DATA ON THE TARGET DISK WILL BE DESTROYED.

set -euo pipefail

REPO_URL="https://github.com/sam/nixos-config.git"  # change if forked
FLAKE_ATTR="hostname"
DISK_NAME="main"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

warn() {
  echo "⚠️  $*" >&2
}

die() {
  echo "❌  $*" >&2
  exit 1
}

confirm() {
  local prompt="$1"
  read -rp "$prompt [y/N] " answer < /dev/tty
  [[ "$answer" =~ ^[Yy]$ ]]
}

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------

if [[ $EUID -ne 0 ]]; then
  die "This script must be run as root (e.g. sudo bash install.sh)"
fi

if ! command -v nix >/dev/null 2>&1; then
  die "'nix' not found. Are you running the NixOS minimal installer?"
fi

# ---------------------------------------------------------------------------
# Network check (Wi-Fi)
# ---------------------------------------------------------------------------

if ! ping -c 1 -W 3 github.com >/dev/null 2>&1; then
  echo ""
  echo "═══════════════════════════════════════════════════════════════════════"
  echo "  No internet connection detected"
  echo "═══════════════════════════════════════════════════════════════════════"
  echo ""
  echo "If you are on Wi-Fi, start the NetworkManager TUI now:"
  echo ""
  echo "    nmtui"
  echo ""
  echo "Choose 'Activate a connection', select your SSID, and enter the password."
  echo "Come back here and press Enter to continue."
  echo ""
  read -rp "Press Enter once you have a network connection..." < /dev/tty

  if ! ping -c 1 -W 3 github.com >/dev/null 2>&1; then
    die "Still no internet connection. Please fix networking and re-run."
  fi
fi

if ! command -v git >/dev/null 2>&1; then
  echo "📦 git not found, installing..."
  nix-shell -p git --run "echo git ready"
fi

# ---------------------------------------------------------------------------
# Clone repo (if not already inside it)
# ---------------------------------------------------------------------------

if [[ -f flake.nix ]]; then
  REPO_DIR="$(pwd)"
  echo "✅  Using current directory: $REPO_DIR"
else
  REPO_DIR="/tmp/nixos-config"
  echo "📥  Cloning repo into $REPO_DIR ..."
  rm -rf "$REPO_DIR"
  git clone "$REPO_URL" "$REPO_DIR"
  cd "$REPO_DIR"
fi

# ---------------------------------------------------------------------------
# Identify target disk
# ---------------------------------------------------------------------------

echo ""
echo "═══════════════════════════════════════════════════════════════════════"
echo "  Available block devices"
echo "═══════════════════════════════════════════════════════════════════════"
lsblk -d -o NAME,SIZE,TYPE,MODEL,TRAN || lsblk -d -o NAME,SIZE,TYPE

echo ""
read -rp "Enter the target disk (e.g. /dev/nvme0n1 or /dev/sda): " DISK_DEVICE < /dev/tty

if [[ -z "$DISK_DEVICE" ]]; then
  die "No disk selected."
fi

if [[ ! -e "$DISK_DEVICE" ]]; then
  die "Device '$DISK_DEVICE' does not exist."
fi

# Detect partitions vs whole disks using lsblk
DISK_TYPE=$(lsblk -no TYPE "$DISK_DEVICE" 2>/dev/null || echo "unknown")
if [[ "$DISK_TYPE" == "part" ]]; then
  warn "You selected a partition ($DISK_DEVICE). disko-install expects a whole disk."
  confirm "Continue anyway?" || die "Aborted."
fi

# ---------------------------------------------------------------------------
# Destruction warning
# ---------------------------------------------------------------------------

echo ""
echo "═══════════════════════════════════════════════════════════════════════"
echo "  ⚠️  DESTRUCTIVE OPERATION WARNING"
echo "═══════════════════════════════════════════════════════════════════════"
echo ""
echo "Target disk : $DISK_DEVICE"
echo "Action      : repartition, LUKS-encrypt, format, install NixOS"
echo "Result      : ALL EXISTING DATA ON $DISK_DEVICE WILL BE LOST"
echo ""

if ! confirm "Type 'y' to DESTROY all data on $DISK_DEVICE and install"; then
  die "Installation aborted by user."
fi

# ---------------------------------------------------------------------------
# Run disko-install
# ---------------------------------------------------------------------------

echo ""
echo "🚀  Starting disko-install on $DISK_DEVICE ..."
echo "    You will be prompted to set the LUKS encryption password."
echo "    This same password will be required at every boot."
echo ""

nix run github:nix-community/disko/latest#disko-install -- \
  --flake ".#${FLAKE_ATTR}" \
  --disk "${DISK_NAME}" "${DISK_DEVICE}"

echo ""
echo "✅  Installation complete!"
echo ""

# ---------------------------------------------------------------------------
# Post-install prompt
# ---------------------------------------------------------------------------

if confirm "Reboot now"; then
  echo "🔄  Rebooting..."
  reboot
else
  echo ""
  echo "📋  Next steps:"
  echo "    1. reboot"
  echo "    2. Log in as 'sam' and run 'passwd' to set your user password"
  echo "    3. nmcli device wifi connect 'SSID' password 'pw'"
  echo ""
fi
