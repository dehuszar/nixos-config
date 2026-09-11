# configuration.nix
#
# Shared NixOS core for every machine: boot, hardware, locale, networking,
# Nix settings, and the `sam` user. The desktop stack lives in
# modules/desktop.nix; VM-only concerns live in modules/vm.nix.
{ pkgs, ... }:

{
  imports = [
    ./modules/desktop.nix
    ./modules/first-boot.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.resumeDevice = "/dev/mapper/crypted";
  boot.kernelParams = [ "resume_offset=27580416" ];
  # --- UEFI Secure Boot (lanzaboote) - commented out until needed ---
  # Requires the lanzaboote input + module in flake.nix; REPLACES systemd-boot.
  # boot.loader.systemd-boot.enable = lib.mkForce false;
  # boot.lanzaboote.enable = true;
  # boot.lanzaboote.pkiBundle = "/var/lib/sbctl";

  # 3D acceleration + firmware. Intel/AMD are both in-kernel DRM drivers + mesa,
  # so one setting covers both; only NVIDIA needs extra driver config.
  # Redistributable firmware covers amdgpu/i915/wifi/bluetooth.
  hardware.bluetooth.enable = true;
  hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = true;

  time.timeZone = "America/Detroit"; # US Eastern (EST/EDT)
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    dust
    git
    gnumake
    jq
    kdePackages.qt5compat
    nss
    nssTools
    openssl
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
  nixpkgs.config.permittedInsecurePackages = [
    "ladybird-0-unstable-2026-06-05"
  ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  programs.steam.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  services.ipp-usb.enable = true;
  services.logind.settings.Login.HandleLidSwitch = "hibernate";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";
  services.printing = {
    enable = true;
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3297", ATTRS{idProduct}=="1977", GROUP="keymapp", MODE="0660"
  '';

  swapDevices = [
    {
      device = "/swapfile";
      size = 65536; # 64GB in megabytes
    }
  ];

  system.stateVersion = "26.11";

  users.groups.keymapp = { };
  users.users.sam = {
    isNormalUser = true;
    # 'wheel' for sudo; 'video'/'input' for DRM & input device access;
    # 'seat' for the seatd socket.
    extraGroups = [
      "keymapp"
      "wheel"
      "video"
      "input"
      "seat"
    ];
  };
}
