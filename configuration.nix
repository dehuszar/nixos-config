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

  # Block ACPI display-toggle events triggered by the GMMS tablet mode
  # switch on ThinkPad Yoga Gen 8, which silently kills the eDP panel.
  boot.kernelParams = [ "acpi_backlight=native" ];

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5;
  };
  boot.loader.efi.canTouchEfiVariables = true;
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
    gdb
    git
    gnumake
    iw
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
  networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.iwd.settings.General.Country = "US";

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    # "ladybird-0-unstable-2026-06-05"
  ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  powerManagement.enable = true;
  programs.steam.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Real-time audio: rtkit manages memlock limits and RT scheduling for
  # PipeWire/JACK clients, preventing audio dropouts from swap activity.
  security.rtkit.enable = true;

  # Enable PipeWire as the system sound server (not just the package).
  # This also enables the JACK compatibility layer by default.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  services.ipp-usb.enable = true;
  services.logind.settings.Login.HandleLidSwitch = "suspend";
  services.logind.settings.Login.HandleLidSwitchDocked = "ignore";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "suspend";
  services.printing = {
    enable = true;
  };
  services.udisks2.enable = true;
  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3297", ATTRS{idProduct}=="1977", GROUP="keymapp", MODE="0660"

    # ThinkPad Yoga Gen 8: inhibit the tablet mode switch (SW_TABLET_MODE)
    # from the "ThinkPad Extra Buttons" input device. When the hinge reaches
    # 360°, the GMMS ACPI switch fires and silently kills the eDP output.
    # Blocking it at the input layer prevents the display from being disabled.
    # Note: this also suppresses thinkpad_acpi hotkey events (Fn keys), but
    # most hotkeys still arrive via the intel-hid driver separately.
    ACTION=="add|change", SUBSYSTEM=="input", ATTRS{name}=="ThinkPad Extra Buttons", ATTR{inhibited}="1"
  '';

  system.stateVersion = "26.11";

  users.groups.keymapp = { };
  users.users.sam = {
    isNormalUser = true;
    # 'wheel' for sudo; 'video'/'input' for DRM & input device access;
    # 'seat' for the seatd socket; 'audio' for real-time audio devices.
    extraGroups = [
      "audio"
      "keymapp"
      "wheel"
      "video"
      "input"
      "seat"
    ];
  };
}
