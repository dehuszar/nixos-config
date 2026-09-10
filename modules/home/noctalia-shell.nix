# modules/home/noctalia.nix
#
# Home Manager configuration for Noctalia shell.
# Provides a sleek, customizable desktop shell for Wayland compositors.
# Replaces quickshell as the shell layer around MangoWM.
{ inputs, config, lib, pkgs, ... }:
{
  imports = [ inputs.noctalia.homeModules.default ];

  # -- Obsidian theme template --
  # Declaratively manage the Obsidian template input file and config.
  # Noctalia's template engine renders obsidian.css into the vault's
  # snippets directory, mapping the active palette to Obsidian CSS vars.
  xdg.configFile = {
    "noctalia/Obsidian/obsidian.css".source = ./obsidian/obsidian.css;
    "noctalia/obsidian.toml".source = ./obsidian/obsidian.toml;
  };

  # Ensure the vault snippets directory exists so Noctalia can write to it.
  home.activation.createObsidianSnippetsDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "/home/sam/Documents/Thoughts and Designs/.obsidian/snippets"
    $DRY_RUN_CMD touch "/home/sam/Documents/Thoughts and Designs/.obsidian/snippets/noctalia.css"
  '';

  programs.noctalia = {
    enable = true;

    # Enable systemd integration for proper session management
    systemd.enable = true;

    settings = {
      # -- Accessibility --
      accessibility = {
        ui_scale = 1.5;
      };

      # -- Bar --
      bar = {
        default = {
          shadow = false;
          contact_shadow = false;
          margin_ends = 0;

          start  = [ "launcher" "workspaces" ];
          center = [ "clock" "media" ];
          end    = [ "notifications" "group:g1" "tray" "clipboard" "bluetooth" "volume" "network" "battery" "session" ];

          capsule_group = [
            {
              id                = "g1";
              enabled           = true;
              fill              = "surface_variant";
              opacity           = 1.0;
              padding           = 6.0;
              accordion         = false;
              accordion_direction = "end";
              members           = [ "wallpaper" "wallhaven" "mpvpaper" ];
            }
          ];
        };
      };

      # -- Calendar --
      calendar.enabled = true;

      # -- Dock --
      dock.shadow = false;

      # -- Location --
      location.auto_locate = true;

      # -- Nightlight --
      nightlight.enabled = true;

      # -- Plugins --
      plugins.enabled = [
        "kenn/keybind-cheatsheet"
        "noctalia/wallhaven"
        "noctalia/mpvpaper"
        "ezequiel/mango_layouts"
        "noctalia/wallpaper_depth"
      ];

      plugin_settings = {
        "kenn/keybind-cheatsheet" = {
          cheatsheet_layer = "overlay";
          compositor       = "mango";
          show_actions     = true;
        };

        "noctalia/mpvpaper" = {
          video_directory = "/home/sam/Pictures/Wallpapers/Videos";
        };

        "noctalia/wallhaven" = {
          download_dir = "/home/sam/Pictures/Wallpapers";
        };
      };

      # -- Shell --
      shell = {
        font                   = "JetBrainsMono Nerd Font";
        settings_show_advanced = true;
        telemetry_enabled      = true;

        panel.shadow = false;
      };

      # -- Theme --
      theme = {
        mode           = "dark";
        source         = "wallpaper";
        builtin        = "Tokyo-Night";
        wallpaper_scheme = "m3-content";

        templates = {
          builtin_ids = [ "btop" "ghostty" "mango" ];
          community_ids = [
            "opencode"
            "pi-agent"
            "pywalfox"
            "blender"
            "gimp"
            "inkscape"
            "neovim"
            "obsidian"
            "steam"
            "obs"
            "fzf"
            "yazi"
          ];
        };
      };

      # -- Idle management (Noctalia built-in) --
      # Lock after 30 min idle, monitor off 15 min after that (45 min total).
      # No suspend — DPMS only.
      idle = {
        behavior_order = [ "lock" "screen-off" "suspend" ];
        pre_action_fade_seconds = 2.0;

        behavior = {
          lock = {
            timeout = 1800;  # 30 min
            action  = "lock";
          };
          screen-off = {
            timeout = 2700;  # 45 min total (15 min after lock)
            action  = "screen_off";
          };
          suspend.enabled = false;  # no suspend on idle
        };
      };

      # -- Lock screen --
      lockscreen = {
        enabled             = true;
        lock_before_suspend = true;
        fingerprint         = true;
        blurred_desktop     = false;
        blur_intensity      = 0.5;
        tint_intensity      = 0.3;
      };

      # -- Weather --
      weather.unit = "imperial";

      # -- Widget settings --
      widget = {
        clock = {
          format = "{:%A, %B %d} - {:%I:%M %p}";
        };

        mpvpaper = {
          type = "noctalia/mpvpaper:mpvpaper";
        };

        wallhaven = {
          type = "noctalia/wallhaven:wallhaven";
        };
      };
    };
  };


}
