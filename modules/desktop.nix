# modules/desktop.nix
#
# The graphical desktop, shared by both the `hostname` and `vm` configs:
# mangowm (compositor), seatd (device access), greetd (login/session).
{ pkgs, ... }:
{
  # NixOS-level mango integration (portal, polkit, session entry).
  # `programs.mango` has no `settings`/`extraConfig` options and writes no
  # config file - the actual mangowm configuration lives on the Home Manager
  # side in modules/home/mango.nix.
  programs.mango.enable = true;

  # seatd: hands wlroots (mangowm) access to the VT + DRM device when it's not
  # running inside a systemd-logind graphical session. Fixes libseat's
  # "Permission denied" errors.
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

  environment.systemPackages = [
    pkgs.greetd
    pkgs.tuigreet
  ];
}
