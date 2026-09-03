#!/usr/bin/env bash
#
# install.sh — NixOS one-shot installer for the minimal installer ISO
#
# Run this on the NixOS minimal installer (or any live environment with Nix).
# The script checks prerequisites, clones the repo, asks for a target disk, and
# runs disko-install to partition, LUKS-encrypt, format, and install in one step.
#
# Because the minimal installer mounts /etc/nix/nix.conf read-only, we use the
# NIX_CONFIG environment variable to enable nix-command and flakes instead of
# editing the system file.  NIX_CONFIG is exported here and preserved across
# every sudo invocation.
#
# Environment:
#   NIX_CONFIG   – inline nix.conf overrides (set automatically by this script).
#   DRY_RUN      – set to any non-empty value (or pass --dry-run) to print the
#                  disko-install command and exit without touching any disk.
#
set -euo pipefail

# ---------------------------------------------------------------------------
# 0. Optional flags
# ---------------------------------------------------------------------------

for arg in "$@"; do
  case "$arg" in
    --help|-h)
      cat <<'HELP'
Usage: ./install.sh [OPTIONS]

Options:
  --dry-run    Print the disko-install command and exit (do not write to disk).
  --help, -h   Show this message.

Environment:
  NIX_CONFIG   Inline nix configuration.  Exported automatically by this script.
  DRY_RUN      Set to any non-empty value to enable dry-run mode.

Examples:
  # Normal install (interactive)
  sudo bash install.sh

  # Dry-run inside a test VM
  DRY_RUN=1 bash install.sh
HELP
      exit 0
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
  esac
done

# ---------------------------------------------------------------------------
# 1. Nix client configuration (set before any nix command runs)
# ---------------------------------------------------------------------------

# The minimal installer ISO mounts /etc/nix/nix.conf read-only.  We override
# settings here so we never need to touch the system file or restart nix-daemon.
export NIX_CONFIG="experimental-features = nix-command flakes"

# Wrapper that preserves NIX_CONFIG across sudo.  sudo resets the environment
# by default, which would silently drop our NIX_CONFIG override.
sudo_nix() {
  if [[ $EUID -eq 0 ]]; then
    "$@"
  else
    sudo --preserve-env=NIX_CONFIG "$@"
  fi
}

# ---------------------------------------------------------------------------
# 2. Helpers
# ---------------------------------------------------------------------------

log()   { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
die()   { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

confirm() {
  local prompt="$1"
  local answer
  read -rp "$prompt [y/N] " answer </dev/tty
  [[ "$answer" =~ ^[Yy]$ ]]
}

# ---------------------------------------------------------------------------
# 3. Verify nix experimental features
# ---------------------------------------------------------------------------

REQUIRED_FEATURES=("nix-command" "flakes")

# Return 0 if every feature in REQUIRED_FEATURES appears as a whole word in the
# given `nix config show` output.
has_all_features() {
  local config_output="$1"
  local line
  line=$(grep -E '^experimental-features' <<< "$config_output" || true)
  [[ -n "$line" ]] || return 1
  for feat in "${REQUIRED_FEATURES[@]}"; do
    grep -qw "$feat" <<< "$line" || return 1
  done
}

# Check both the current-user client config and the root/daemon config.
# Both must pass before we run any nix command that hits the store.
verify_nix_features() {
  local user_conf daemon_conf

  user_conf=$(nix config show 2>/dev/null) ||
    die "'nix config show' failed — is nix on PATH?"

  daemon_conf=$(sudo_nix nix config show 2>/dev/null) ||
    die "'sudo nix config show' failed — check sudo access / nix-daemon."

  local user_ok=1 daemon_ok=1
  has_all_features "$user_conf"  && user_ok=0
  has_all_features "$daemon_conf" && daemon_ok=0

  if [[ $user_ok -eq 0 && $daemon_ok -eq 0 ]]; then
    return 0
  fi

  warn "client config:  $([[ $user_ok  -eq 0 ]] && echo OK || echo MISSING)"
  warn "daemon config:  $([[ $daemon_ok -eq 0 ]] && echo OK || echo MISSING)"
  return 1
}

ensure_nix_features() {
  log "Checking nix experimental features (client + daemon)..."

  if verify_nix_features; then
    log "nix-command and flakes are enabled.  Continuing."
    return 0
  fi

  # NIX_CONFIG is already exported above.  If the check still fails, the
  # daemon configuration on this ISO is missing the features (rare on modern
  # NixOS minimal installers, which normally pre-enable them).
  die "nix-command / flakes are not enabled in the daemon configuration.  \
On the NixOS minimal installer these features are normally pre-enabled.  \
If you are on a custom or very old ISO, try remounting the root filesystem \
read-write:  sudo mount -o remount,rw /"
}

# ---------------------------------------------------------------------------
# 4. Pre-flight
# ---------------------------------------------------------------------------

if [[ $EUID -ne 0 ]]; then
  log "Not running as root.  Root privileges will be requested via sudo when needed."
fi

command -v nix >/dev/null 2>&1 ||
  die "'nix' not found.  Are you on the NixOS minimal installer?"

command -v sudo >/dev/null 2>&1 ||
  die "'sudo' not found.  This script uses sudo to preserve the NIX_CONFIG environment variable."

ensure_nix_features

# ---------------------------------------------------------------------------
# 5. Network check
# ---------------------------------------------------------------------------

if ! ping -c 1 -W 3 github.com >/dev/null 2>&1; then
  cat <<'NET'
═══════════════════════════════════════════════════════════════════════
  No internet connection detected
═══════════════════════════════════════════════════════════════════════

If you are on Wi-Fi, start the NetworkManager TUI now:

    nmtui

Choose 'Activate a connection', select your SSID, and enter the password.
Come back here and press Enter to continue.
NET
  read -rp "Press Enter once you have a network connection..." </dev/tty

  if ! ping -c 1 -W 3 github.com >/dev/null 2>&1; then
    die "Still no internet connection. Please fix networking and re-run."
  fi
fi

# ---------------------------------------------------------------------------
# 6. Ensure git is available
# ---------------------------------------------------------------------------

if ! command -v git >/dev/null 2>&1; then
  log "git not found, installing via nix-shell..."
  nix-shell -p git --run "echo git ready"
fi

# ---------------------------------------------------------------------------
# 7. Clone / locate the repo
# ---------------------------------------------------------------------------

REPO_URL="https://github.com/dehuszar/nixos-config.git"
FLAKE_ATTR="hostname"
DISK_NAME="main"

if [[ -f flake.nix ]]; then
  REPO_DIR=$(pwd)
  log "Using current directory: $REPO_DIR"
else
  REPO_DIR="/tmp/nixos-config"
  log "Cloning repo into $REPO_DIR..."
  rm -rf "$REPO_DIR"
  git clone "$REPO_URL" "$REPO_DIR"
  cd "$REPO_DIR"
fi

# ---------------------------------------------------------------------------
# 8. Identify target disk
# ---------------------------------------------------------------------------

cat <<'DISK'
═══════════════════════════════════════════════════════════════════════
  Available block devices
═══════════════════════════════════════════════════════════════════════
DISK
lsblk -d -o NAME,SIZE,TYPE,MODEL,TRAN || lsblk -d -o NAME,SIZE,TYPE

echo ""
read -rp "Enter the target disk (e.g. /dev/nvme0n1 or /dev/sda): " DISK_DEVICE </dev/tty

[[ -n "$DISK_DEVICE" ]] || die "No disk selected."
[[ -e "$DISK_DEVICE" ]] || die "Device '$DISK_DEVICE' does not exist."

DISK_TYPE=$(lsblk -no TYPE "$DISK_DEVICE" 2>/dev/null || echo "unknown")
if [[ "$DISK_TYPE" == "part" ]]; then
  warn "You selected a partition ($DISK_DEVICE).  disko-install expects a whole disk."
  confirm "Continue anyway?" || die "Aborted."
fi

# ---------------------------------------------------------------------------
# 9. Destruction warning
# ---------------------------------------------------------------------------

cat <<WARN

═══════════════════════════════════════════════════════════════════════
  ⚠️  DESTRUCTIVE OPERATION WARNING
═══════════════════════════════════════════════════════════════════════

Target disk : $DISK_DEVICE
Action      : repartition, LUKS-encrypt, format, install NixOS
Result      : ALL EXISTING DATA ON $DISK_DEVICE WILL BE LOST

WARN

confirm "Type 'y' to DESTROY all data on $DISK_DEVICE and install" ||
  die "Installation aborted by user."

# ---------------------------------------------------------------------------
# 10. disko-install (or dry-run)
# ---------------------------------------------------------------------------

if [[ -n "${DRY_RUN:-}" ]]; then
  log "DRY RUN — would execute:"
  echo ""
  echo "  sudo_nix nix run github:nix-community/disko/latest#disko-install -- \\"
  echo "      --flake '.#${FLAKE_ATTR}' \\"
  echo "      --disk '${DISK_NAME}' '${DISK_DEVICE}'"
  echo ""
  log "Exiting without making any changes."
  exit 0
fi

log "Starting disko-install on $DISK_DEVICE..."
warn "You will be prompted to set the LUKS encryption password."
warn "This same password will be required at every boot."
echo ""

sudo_nix nix run github:nix-community/disko/latest#disko-install -- \
  --flake ".#${FLAKE_ATTR}" \
  --disk "${DISK_NAME}" "${DISK_DEVICE}"

log "Installation complete!"

# ---------------------------------------------------------------------------
# 11. Post-install
# ---------------------------------------------------------------------------

if confirm "Reboot now"; then
  log "Rebooting..."
  sudo_nix reboot
else
  cat <<'POST'

📋  Next steps:
    1. reboot
    2. Log in as 'sam' and run 'passwd' to set your user password
    3. nmcli device wifi connect 'SSID' password 'pw'

POST
fi
