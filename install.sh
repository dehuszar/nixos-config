#!/usr/bin/env bash
# install.sh
#
# One-shot install script. Every step is meant to run unattended from the
# minimal installer shell, so we fail loudly and early rather than limping
# into a disko run against a half-configured nix.
set -euo pipefail

NIX_CONF="/etc/nix/nix.conf"
REQUIRED_FEATURES=("nix-command" "flakes")

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
confirm() {
  local prompt="$1"
  read -rp "$prompt [y/N] " answer </dev/tty
  [[ "$answer" =~ ^[Yy]$ ]]
}
log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
die() {
  printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2
  exit 1
}

# --- feature verification -------------------------------------------------

# Extracts the experimental-features line from a `nix show-config` blob and
# confirms every entry in REQUIRED_FEATURES appears as a whole word.
# Returns 0 (pass) or 1 (fail).
has_all_features() {
  local conf_output="$1"
  local line
  line="$(grep -E '^experimental-features' <<<"$conf_output" || true)"
  [[ -n "$line" ]] || return 1
  for feat in "${REQUIRED_FEATURES[@]}"; do
    grep -qw "$feat" <<<"$line" || return 1
  done
  return 0
}

# Checks BOTH the client-side config and the config the nix-daemon is
# actually enforcing. Both must pass — matches the failure mode we saw
# where NIX_CONFIG satisfied the client but not the daemon disko calls
# under sudo.
verify_nix_features() {
  local user_conf daemon_conf
  user_conf="$(nix show-config 2>/dev/null)" ||
    die "'nix show-config' failed — is nix on PATH in this shell?"
  daemon_conf="$(sudo nix show-config 2>/dev/null)" ||
    die "'sudo nix show-config' failed — check sudo access / nix-daemon status."

  local user_ok=1 daemon_ok=1
  has_all_features "$user_conf" && user_ok=0
  has_all_features "$daemon_conf" && daemon_ok=0

  if [[ $user_ok -eq 0 && $daemon_ok -eq 0 ]]; then
    return 0
  fi

  warn "client config:  $([[ $user_ok -eq 0 ]] && echo OK || echo MISSING nix-command/flakes)"
  warn "daemon config:  $([[ $daemon_ok -eq 0 ]] && echo OK || echo MISSING nix-command/flakes)"
  return 1
}

# Edits /etc/nix/nix.conf directly (not NIX_CONFIG — that doesn't survive
# sudo's env reset) and restarts nix-daemon so it picks up the change,
# then re-verifies. Dies with a clear message if it still doesn't stick,
# rather than letting later disko/nixos-install steps fail with a
# confusing error.
ensure_nix_features() {
  log "Checking nix-command/flakes availability (client + daemon)..."
  if verify_nix_features; then
    log "nix-command and flakes already enabled. Continuing."
    return 0
  fi

  warn "Experimental features not fully enabled. Patching ${NIX_CONF}..."

  if grep -q '^experimental-features' "$NIX_CONF" 2>/dev/null; then
    sudo sed -i -E 's/^experimental-features.*/experimental-features = nix-command flakes/' "$NIX_CONF"
  else
    echo "experimental-features = nix-command flakes" | sudo tee -a "$NIX_CONF" >/dev/null
  fi

  log "Restarting nix-daemon..."
  sudo systemctl restart nix-daemon

  # give the daemon a few seconds to come back before we hammer it
  local i
  for i in $(seq 1 10); do
    sudo systemctl is-active --quiet nix-daemon && break
    sleep 1
  done
  sudo systemctl is-active --quiet nix-daemon ||
    die "nix-daemon did not return to an active state after restart. Check: sudo systemctl status nix-daemon"

  log "Re-verifying..."
  if ! verify_nix_features; then
    die "nix-command/flakes still not enabled after patching ${NIX_CONF} and restarting nix-daemon. \
Check 'nix show-config' and 'sudo nix show-config' manually. If a later command names a DIFFERENT \
feature (e.g. auto-allocate-uids, cgroups), that's a separate flag — add it to REQUIRED_FEATURES above \
and re-run, don't assume this same fix applies."
  fi

  log "nix-command and flakes confirmed enabled for both client and daemon."
}

# --- main -------------------------------------------------------------

ensure_nix_features

# Everything below only runs once the check above has either passed or
# fixed-and-reverified the config, so disko/nixos-install never run
# against a nix that can't do what they're about to ask of it.

REPO_URL="https://github.com/sam/nixos-config.git" # change if forked
FLAKE_ATTR="hostname"
DISK_NAME="main"

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
  read -rp "Press Enter once you have a network connection..." </dev/tty

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
read -rp "Enter the target disk (e.g. /dev/nvme0n1 or /dev/sda): " DISK_DEVICE </dev/tty

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
