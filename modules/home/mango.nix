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
      After = [ "default.target" ];
      PartOf = [ "default.target" ];
    };
    Service = {
      ExecStart = "%h/.local/bin/mango-dock-inhibit";
      Restart = "always";
      RestartSec = 2;
    };
    Install = {
      WantedBy = [ "default.target" ];
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
      #
      # Hotplug-safe: skips sending commands while any DRM hotplug event
      # is pending (detected via udev monitor) to avoid racing with
      # mangowm's output reconfiguration, which would crash the compositor.

      LID_STATE="/proc/acpi/button/lid/LID/state"
      CURRENT_STATE=""

      # Watch for DRM hotplug events so we can back off during transitions.
      HOTPLUG_FIF="/tmp/mango-lid-hotplug.fifo"
      mkfifo "$HOTPLUG_FIF" 2>/dev/null || true

      # Start a background udev monitor for DRM hotplug events.
      # Each event writes a timestamp to a temp file.
      # stdbuf forces line-buffered output so events aren't stuck in pipe buffers.
      HOTPLUG_TS="/tmp/mango-lid-hotplug.ts"
      (
        stdbuf -oL udevadm monitor --udev --subsystem-match=drm 2>/dev/null | while read -r _; do
          date +%s > "$HOTPLUG_TS"
        done
      ) &
      UDEV_PID=$!

      # Seed the timestamp so the first loop iteration has a grace period.
      # Without this, last_hotplug() returns 0 and in_hotplug_window() is
      # immediately false — firing wlr-randr before mangowm is ready.
      date +%s > "$HOTPLUG_TS"

      last_hotplug() {
        [ -f "$HOTPLUG_TS" ] && cat "$HOTPLUG_TS" 2>/dev/null || echo 0
      }

      in_hotplug_window() {
        now=$(date +%s)
        ts=$(last_hotplug)
        # If a hotplug event happened in the last 3 seconds, back off.
        [ $((now - ts)) -lt 3 ] && return 0
        return 1
      }

      cleanup() {
        kill "$UDEV_PID" 2>/dev/null || true
        rm -f "$HOTPLUG_FIF" "$HOTPLUG_TS"
      }
      trap cleanup EXIT

      while true; do
        # DP-3 is the same physical port as HDMI-A-1; always kill it if it
        # gets activated during a hotplug transition.
        # Only run this when NOT in a hotplug window to avoid crashing mangowm.
        if ! in_hotplug_window; then
          if wlr-randr 2>/dev/null | grep -A10 "^DP-3" | grep -q "Enabled: yes"; then
            mmsg dispatch disable_monitor,DP-3 2>/dev/null || true
          fi
        fi

        # Lid close/open — always process regardless of hotplug state.
        # These are ACPI events, not DRM hotplugs, so they're safe to send.
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
      After = [ "default.target" ];
      PartOf = [ "default.target" ];
    };
    Service = {
      ExecStart = "%h/.local/bin/mango-lid-monitor";
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
