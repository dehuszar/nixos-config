# modules/desktop.nix
#
# The graphical desktop, shared by both the `hostname` and `vm` configs:
# mangowm (compositor), seatd (device access), greetd (login/session).
{ pkgs, lib, isVM, ... }:
{
  # NixOS-level mango integration (portal, polkit, session entry).
  # `programs.mango` has no `settings`/`extraConfig` options and writes no
  # config file - the actual mangowm configuration lives on the Home Manager
  # side in modules/home/mango.nix.
  programs.mango.enable = true;

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

  # Not sure this is going to work until I'm on real hardware
  services.power-profiles-daemon.enable = lib.mkIf (!isVM) true;

  # seatd: hands wlroots (mangowm) access to the VT + DRM device when it's not
  # running inside a systemd-logind graphical session. Fixes libseat's
  # "Permission denied" errors.
  services.seatd.enable = true;

  services.upower.enable = true;

  environment.systemPackages = with pkgs; [
    btop
    cliphist
    ddcutil
    greetd
    mpvpaper
    noto-fonts
    pipewire
    pipewire-control-center
    pywalfox-native
    qt6.qt3d
    qt6.qtbase
    tuigreet
    wiremix
    wl-clip-persist
    wl-clipboard
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-wlr
    yazi
  ];
}
