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
        "mmsg dispatch disable_monitor,DP-3"
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

  # ── Dock inhibitor ────────────────────────────────────────────────────
  # Holds a systemd sleep-inhibit lock while HDMI-A-1 is connected.
  home.file.".local/bin/mango-dock-inhibit" = {
    executable = true;
    text = ''
      #!/bin/sh
      # Polls DRM connector status.  While HDMI-A-1 is "connected",
      # holds a systemd sleep inhibitor so lid-close does not suspend.

      HDMI_STATUS="/sys/class/drm/card1-HDMI-A-1/status"

      INHIBIT_PID=""

      has_external() {
        [ -f "$HDMI_STATUS" ] && [ "$(cat "$HDMI_STATUS" 2>/dev/null)" = "connected" ] && return 0
        return 1
      }

      start_inhibit() {
        if [ -z "$INHIBIT_PID" ]; then
          systemd-inhibit \
            --what=sleep \
            --who="mango-dock-inhibit" \
            --why="External monitor connected; suspending would disconnect display" \
            --mode=block \
            sleep infinity &
          INHIBIT_PID=$!
        fi
      }

      stop_inhibit() {
        if [ -n "$INHIBIT_PID" ]; then
          kill "$INHIBIT_PID" 2>/dev/null || true
          wait "$INHIBIT_PID" 2>/dev/null || true
          INHIBIT_PID=""
        fi
      }

      while true; do
        if has_external; then
          start_inhibit
        else
          stop_inhibit
        fi
        sleep 3
      done
    '';
  };

  systemd.user.services.mango-dock-inhibit = {
    Unit = {
      Description = "Inhibit suspend while external monitor is connected";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "%h/.local/bin/mango-dock-inhibit";
      Restart = "always";
      RestartSec = 2;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # ── Lid-close monitor ─────────────────────────────────────────────────
  # Disables eDP-1 when the laptop lid is shut.
  home.file.".local/bin/mango-lid-monitor" = {
    executable = true;
    text = ''
      #!/bin/sh
      # Monitors the ACPI lid switch and toggles eDP-1 via mmsg.
      # Runs as a systemd user service alongside mangowm.

      LID_STATE="/proc/acpi/button/lid/LID/state"
      CURRENT_STATE=""

      while true; do
        if [ -f "$LID_STATE" ]; then
          STATE=$(awk '{print $2}' "$LID_STATE" 2>/dev/null)
          if [ -n "$STATE" ] && [ "$STATE" != "$CURRENT_STATE" ]; then
            CURRENT_STATE="$STATE"
            if [ "$STATE" = "closed" ]; then
              # Lid closed — disable the internal display
              mmsg dispatch disable_monitor,eDP-1 2>/dev/null || true
            else
              # Lid open — re-enable the internal display
              mmsg dispatch enable_monitor,eDP-1 2>/dev/null || true
            fi
          fi
        fi
        sleep 1
      done
    '';
  };

  systemd.user.services.mango-lid-monitor = {
    Unit = {
      Description = "Toggle eDP-1 on laptop lid close/open for mangowm";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "%h/.local/bin/mango-lid-monitor";
      Restart = "always";
      RestartSec = 2;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
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
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "%h/.local/bin/mango-auto-rotate";
      Restart = "always";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
