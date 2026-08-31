{
  config,
  pkgs,
  lib,
  isVM ? false,
  ...
}:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # --- UEFI Secure Boot (lanzaboote) — commented out until needed ---
  # Requires the lanzaboote input + module in flake.nix. `pkiBundle` is where
  # the enrolled keys live (sbctl-managed at /var/lib/sbctl by default).
  # Lanzaboote REPLACES systemd-boot, so that loader gets disabled here.
  # boot.loader.systemd-boot.enable = lib.mkForce false;
  # boot.lanzaboote.enable = true;
  # boot.lanzaboote.pkiBundle = "/var/lib/sbctl";

  # 3D acceleration + firmware. Real hardware needs GPU GL now that mangowm's
  # `env` is empty (no software fallback). Intel today / AMD in the future are
  # both in-kernel drivers + mesa (DRM modesetting), so one setting covers both;
  # only NVIDIA would need extra driver config. Redistributable firmware covers
  # amdgpu/i915/wifi/bluetooth.
  hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = true;

  time.timeZone = "America/Detroit"; # US Eastern (EST/EDT)
  i18n.defaultLocale = "en_US.UTF-8";
  environment.systemPackages = with pkgs; [
    git
    greetd
    neovim
    tuigreet
    wget
    # sbctl   # uncomment with the Secure Boot block above (manages /var/lib/sbctl keys)
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
  # NixOS-level mango setup (portal, polkit, session entry).
  # NOTE: programs.mango has no `settings`/`extraConfig` options and writes
  # no config file. The actual mangowm config lives on the Home Manager
  # module `wayland.windowManager.mango` in home.nix.
  programs.mango.enable = true;
  # seatd: session manager that hands wlroots (mangowm) access to the
  # VT + DRM device when it's not running inside a systemd-logind
  # graphical session. Required to fix libseat's "Permission denied" errors.
  services.seatd.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "mango";
        user = "sam"; # auto-login on first start, no password required
      };
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --cmd mango";
        user = "greeter";
      };
    };
  };
  system.stateVersion = "26.11";

  users.users.sam = {
    isNormalUser = true;
    # 'wheel' for sudo; 'video'/'input' for DRM & input device access;
    # 'seat' for the seatd socket (NixOS default seatd group).
    extraGroups = [
      "wheel"
      "video"
      "input"
      "seat"
    ];
    # Password is VM-only: the serial/CLI login (`make run-cli`) needs
    # credentials, but this repo is public so a usable password must NOT ship
    # in the real-hardware config. The graphical desktop auto-logs in via
    # greetd (no password), so only the serial console depends on this.
    # Real hardware sets its own password at install / via `passwd`. Using a
    # hash (not initialPassword) avoids NixOS's plaintext-in-config warning.
    hashedPassword = lib.mkIf isVM "$6$opensslmixed$XIukNLliTMwtHbFe.cIH.esPnPQcBXcEMUmrffMGRNcEY4lvxthPFZ2h0ChoS88VSVd07EUhUcBnuRHDhZSDF/";
  };
}
