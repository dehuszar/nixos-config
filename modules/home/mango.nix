# modules/home/mango.nix
#
# Home Manager side of mangowm: writes ~/.config/mango/config.conf from the
# structured `settings` below.
{ inputs, pkgs, ... }:

let
  # Spawn script: opens three separate ghostty windows (nvim, pi-sbx,
  # shell) and switches to workspace 9 to show them.
  nixosConfigScript = pkgs.writeShellScript "nixos-config" ''
    all_running=true

    # Guard: only spawn windows that aren't already running
    if ! pgrep -f "ghostty.*--class=nixos-config-nvim" >/dev/null 2>&1; then
      all_running=false
      ghostty --class=nixos-config-nvim --title="nvim" \
        --working-directory=/home/sam/nixos-config \
        -e nvim &
    fi

    if ! pgrep -f "ghostty.*--class=nixos-config-sbx" >/dev/null 2>&1; then
      all_running=false
      ghostty --class=nixos-config-sbx --title="pi-sbx" \
        --working-directory=/home/sam/nixos-config \
        -e bash -c "pi-sbx.sh nixos-config" &
    fi

    if ! pgrep -f "ghostty.*--class=nixos-config-shell" >/dev/null 2>&1; then
      all_running=false
      ghostty --class=nixos-config-shell --title="shell" \
        --working-directory=/home/sam/nixos-config \
        -e bash &
    fi

    if [ "$all_running" = true ]; then
      # All three already running — just give mango a moment to settle
      sleep 0.2
    else
      # Wait for newly spawned windows to appear
      wait
      sleep 0.5
    fi

    # Switch to workspace 9 via mango's IPC (view takes a bitmask;
    # tag 9 = 1 << 8 = 256)
    mmsg dispatch view,256 2>/dev/null || true
  '';
in
{
  imports = [ inputs.mangowm.hmModules.mango ];

  wayland.windowManager.mango = {
    enable = true;
    # Raw config lines appended verbatim (unsupported/advanced opts)
    extraConfig = "";
    settings = {
      # Renderer env. With the VM now exposing a real accelerated GPU via
      # virtio-gpu/virgl (see modules/vm.nix), mangowm should use hardware GL
      # just like on the real machine. The old VM workaround
      # (WLR_RENDERER_ALLOW_SOFTWARE / LIBGL_ALWAYS_SOFTWARE /
      # WLR_DRM_NO_ATOMIC) is no longer set because LIBGL_ALWAYS_SOFTWARE would
      # force llvmpipe even when virgl is available, turning the screen black.
      # If virgl is ever unavailable, temporarily re-add those vars.
      env = [ ];
      exec-once = "noctalia";
      source = "~/.config/mango/noctalia.conf";

      # Blur and shadows
      blur=1;
      blur_layer=0;
      blur_optimized=1;
      blur_params_num_passes=2;
      blur_params_radius=5;
      blur_params_noise=0.02;
      blur_params_brightness=0.9;
      blur_params_contrast=0.9;
      blur_params_saturation=1.0;
      layer_animations=0;
      
      shadows=1;
      layer_shadows=0;
      shadow_only_floating=0;
      shadows_size=4;
      shadows_blur=12;
      shadows_position_x=2;
      shadows_position_y=2;
      shadowscolor="0x000000ff";

      # Window effects
      border_radius = 6;
      focused_opacity = 1.0;
      unfocused_opacity = 1.0;

      # fx post-processing (animations) is left off to keep the VM's
      # render/blit path simple (works under virgl and llvmpipe alike).
      animations = 1;

      # Multi-monitor: allow directional focus (Super+Arrows) to cross
      # monitor boundaries natively, no script needed.
      focus_cross_monitor=1;

      # Window rules
      windowrule = [
        "tags:9,title:^nvim$"
        "tags:9,title:^pi-sbx$"
        "tags:9,title:^shell$"
      ];

      # Repeatable key -> list of comma-separated bindings.
      # Action names mirror mango's bundled default config.
      bind = [
        # System
        "SUPER,comma,spawn,noctalia msg settings-toggle" # "Noctalia Settings"
        "SUPER,s,spawn,noctalia msg panel-toggle control-center"
        "SUPER,space,spawn,noctalia msg panel-toggle launcher"
        "Super+SHIFT,f,togglefullscreen,"
        "Super,g,toggleglobal"
        "SUPER,k,spawn,noctalia msg panel-toggle kenn/keybind-cheatsheet:cheatsheet"
        "Super,q,killclient,"
        "Super+SHIFT,r,reload_config"
        "Super,Return,spawn,ghostty" #"Terminal"
        "Super,b,spawn,firefox" #"Web browser"

        # Workspace / tag switching (Super+1 through Super+9) — synced across all monitors
        "Super,1,view,1,1"
        "Super,2,view,2,1"
        "Super,3,view,3,1"
        "Super,4,view,4,1"
        "Super,5,view,5,1"
        "Super,6,view,6,1"
        "Super,7,view,7,1"
        "Super,8,view,8,1"
        "Super,9,view,9,1"

        # Focus and Movement
        "Alt,Tab,focuslast"
        "Super,Down,focusdir,down"
        "Super,Left,focusdir,left"
        "Super,Right,focusdir,right"
        "Super,Up,focusdir,up"
        "Super+SHIFT,Down,focus_window_or_workspace,down"
        "Super+SHIFT,Left,focus_window_or_workspace,left"
        "Super+SHIFT,Right,focus_window_or_workspace,right"
        "Super+SHIFT,Up,focus_window_or_workspace,up"

        # Layouts
        "Super,F2,setlayout,scroller"
        "Super,F1,setlayout,tile"

        # Move focused window to tag (Super+Shift+1 through Super+Shift+9)
        "SUPER+SHIFT,1,tag,1"
        "SUPER+SHIFT,2,tag,2"
        "SUPER+SHIFT,3,tag,3"
        "SUPER+SHIFT,4,tag,4"
        "SUPER+SHIFT,5,tag,5"
        "SUPER+SHIFT,6,tag,6"
        "SUPER+SHIFT,7,tag,7"
        "SUPER+SHIFT,8,tag,8"
        "SUPER+SHIFT,9,tag,9"

        # Move focused window to tag, but preserve current workspace
        # (Super+Alt+1 through Super+Alt+9)
        "SUPER+ALT,1,tagsilent,1"
        "SUPER+ALT,2,tagsilent,2"
        "SUPER+ALT,3,tagsilent,3"
        "SUPER+ALT,4,tagsilent,4"
        "SUPER+ALT,5,tagsilent,5"
        "SUPER+ALT,6,tagsilent,6"
        "SUPER+ALT,7,tagsilent,7"
        "SUPER+ALT,8,tagsilent,8"
        "SUPER+ALT,9,tagsilent,9"

        # Swap/reorder windows
        "Super+ALT,Down,exchange_client,down"
        "Super+ALT,Left,exchange_client,left"
        "Super+ALT,Right,exchange_client,right"
        "Super+ALT,Up,exchange_client,up"

        # Move focused window to adjacent monitor (keep same tag)
        "Super+CTRL,Down,tagmon,down,1"
        "Super+CTRL,Left,tagmon,left,1"
        "Super+CTRL,Right,tagmon,right,1"
        "Super+CTRL,Up,tagmon,up,1"

        # Resize mode (enters a submap for keyboard resizing)
        "Super+CTRL,r,setkeymode,resize"

        # Media keys
        "NONE,XF86AudioRaiseVolume,spawn,noctalia msg volume-up"
        "NONE,XF86AudioLowerVolume,spawn,noctalia msg volume-down"
        "NONE,XF86AudioMute,spawn,noctalia msg volume-mute"
        "NONE,XF86MonBrightnessUp,spawn,noctalia msg brightness-up"
        "NONE,XF86MonBrightnessDown,spawn,noctalia msg brightness-down"


        # App launchers

        # TUI launchers
        "Super,n,spawn,ghostty -e nvim" # Nvim code editor (TUI)
        "Super,f,spawn,ghostty -e yazi" # File Browser (TUI)

        # Dev workspace: nvim + pi-sbx + shell on workspace 9
        "SUPER,z,spawn,${nixosConfigScript}"
      ];
      keymode = {
        resize = {
          bind = [
            "NONE,Left,resizewin,-10,0"
            "NONE,Right,resizewin,+10,0"
            "NONE,Up,resizewin,0,-10"
            "NONE,Down,resizewin,0,+10"
            "NONE,Escape,setkeymode,default"
          ];
        };
      };
    };
    systemd.enable = true;
    systemd.xdgAutostart = true;
  };

  # kanshi: dynamic output management
  #
  # Profiles are matched top-to-bottom; first match wins. Matching is based on
  # which outputs are physically connected (not which are enabled/disabled).
  # Outputs with `status = "disable"` do not block matching — they simply
  # disable that output if it happens to be present.
  services.kanshi = {
    enable = true;
    settings = [
      # Laptop + HDMI (DP-3 disabled to avoid duplicate of same physical monitor)
      {
        profile.name = "docked";
        profile.outputs = [
          {
            criteria = "HDMI-A-1";
            status = "enable";
            position = "0,0";
            mode = "3840x2160@60Hz";
          }
          { criteria = "eDP-1"; status = "enable"; position = "3840,960"; }
          { criteria = "DP-3"; status = "disable"; }
        ];
      }
      # Laptop + USB-C DP alt mode (HDMI not plugged in — fallback)
      {
        profile.name = "dp-fallback";
        profile.outputs = [
          {
            criteria = "DP-3";
            status = "enable";
            position = "0,0";
            mode = "3840x2160@60Hz";
          }
          { criteria = "eDP-1"; status = "enable"; position = "3840,960"; }
        ];
      }
      # Laptop only (no external display connected)
      {
        profile.name = "laptop-only";
        profile.outputs = [
          { criteria = "eDP-1"; status = "enable"; position = "0,0"; }
        ];
      }
    ];
  };

  # Lid-close monitor: disables eDP-1 when the laptop lid is shut so that
  # mangowm moves all windows to the remaining external monitor.
  # Re-enables eDP-1 when the lid opens.
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
}
