# configuration.nix
#
# Shared NixOS core for every machine: boot, hardware, locale, networking,
# Nix settings, and the `sam` user. The desktop stack lives in
# modules/desktop.nix; VM-only concerns live in modules/vm.nix.
{ pkgs, ... }:

{
  imports = [ ./modules/desktop.nix ./modules/first-boot.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # --- UEFI Secure Boot (lanzaboote) - commented out until needed ---
  # Requires the lanzaboote input + module in flake.nix; REPLACES systemd-boot.
  # boot.loader.systemd-boot.enable = lib.mkForce false;
  # boot.lanzaboote.enable = true;
  # boot.lanzaboote.pkiBundle = "/var/lib/sbctl";

  # 3D acceleration + firmware. Intel/AMD are both in-kernel DRM drivers + mesa,
  # so one setting covers both; only NVIDIA needs extra driver config.
  # Redistributable firmware covers amdgpu/i915/wifi/bluetooth.
  hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = true;

  time.timeZone = "America/Detroit"; # US Eastern (EST/EDT)
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    git
    gnumake
    kdePackages.qt5compat
    quickshell
    # sbctl   # uncomment with the Secure Boot block above
    wget
    yazi
  ];
  environment.variables.EDITOR = "nvim";
  environment.variables.SUDO_EDITOR = "nvim";

  networking.hostName = "creation-station";
  networking.networkmanager.enable = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "26.11";

  users.users.sam = {
    isNormalUser = true;
    # 'wheel' for sudo; 'video'/'input' for DRM & input device access;
    # 'seat' for the seatd socket.
    extraGroups = [
      "wheel"
      "video"
      "input"
      "seat"
    ];
  };
}
