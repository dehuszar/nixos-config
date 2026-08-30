{ config, pkgs, isVM ? false, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  environment.systemPackages = with pkgs; [
    git
    greetd
    neovim
    tuigreet
    wget
    yazi
  ];
  environment.variables.EDITOR = "nvim";
  environment.variables.SUDO_EDITOR = "nvim";
  networking.hostName = "creation-station";
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
    extraGroups = [ "wheel" "video" "input" "seat" ];
    initialPassword = "test";
  };
}
