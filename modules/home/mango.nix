# modules/home/mango.nix
#
# Home Manager side of mangowm: minimal Nix config that sources everything
# from ~/.config/mango/*.conf so you can iterate without rebuilding.
{
  inputs,
  pkgs,
  lib,
  ...
}:

{
  imports = [ inputs.mangowm.hmModules.mango ];

  # ── Mango: enable + source external config ────────────────────────────
  wayland.windowManager.mango = {
    enable = true;
    extraConfig = "";
    settings = {
      env = [ ];
      exec-once = [
        "noctalia"
      ];
      # All bindings, blur, shadows, window rules, etc. live in this file —
      # editable without a Nix rebuild.  Reload with Super+Shift+R or let
      # the config watcher pick up changes automatically.
      source = "~/.config/mango/mango.conf";
    };
    systemd.enable = true;
    systemd.xdgAutostart = true;
  };

  # ── Install config files & scripts ────────────────────────────────────
  # The watcher auto-reloads ~/.config/mango/mango.conf when its mtime
  # changes.  That file should be a symlink to the repo copy so you can
  # edit without rebuilding.

  home.file.".local/bin/nixos-config-spawn" = {
    source = ../mango/nixos-config-spawn;
    executable = true;
  };

  home.file.".local/bin/mango-config-watcher" = {
    source = ../mango/mango-config-watcher;
    executable = true;
  };

  home.file.".local/bin/screenshot" = {
    source = ../mango/screenshot;
    executable = true;
  };

  # ── Symlink mango.conf so the repo copy is authoritative ──────────────
  # Runs after writeBoundary so it overrides any Nix store symlink created
  # by the upstream mangowm HM module.  Direct symlink (bypasses the Nix
  # store) so the config watcher sees mtime changes when you edit the repo
  # copy.  The watcher polls ~/.config/mango/mango.conf and runs
  # `mmsg dispatch reload_config`.
  home.activation.mango-conf-symlink = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD ln -sf "$HOME/nix/nixos-config/modules/mango/mango.conf" "$HOME/.config/mango/mango.conf"
  '';

  # ── Config watcher service ────────────────────────────────────────────
  # Polls ~/.config/mango/*.conf every second.  When mtime changes,
  # runs `mmsg dispatch reload_config`.
  systemd.user.services.mango-config-watcher = {
    Unit = {
      Description = "Watch Mango config files and hot-reload on change";
    };
    Service = {
      ExecStart = "%h/.local/bin/mango-config-watcher";
      Restart = "always";
      RestartSec = 2;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # ── Auto-rotate (accelerometer → screen transform) ───────────────
  # Reads the accelerometer directly from /sys/bus/iio/devices/ and
  # rotates eDP-1 via wlr-randr to match how you're holding the Yoga.
  home.file.".local/bin/mango-auto-rotate" = {
    source = ../mango/mango-auto-rotate;
    executable = true;
  };

  systemd.user.services.mango-auto-rotate = {
    Unit = {
      Description = "Auto-rotate Mango display based on accelerometer orientation";
      After = [ "default.target" ];
      PartOf = [ "default.target" ];
    };
    Service = {
      ExecStart = "%h/.local/bin/mango-auto-rotate";
      Restart = "always";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
