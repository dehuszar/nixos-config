# modules/home/mangobar.nix
#
# Home Manager configuration for mangobar — a simple Wayland status bar
# for mangowm.  Replaces noctalia's bar/panel layer.
{
  pkgs,
  lib,
  ...
}:

{
  # -- mangobar --
  services.mangobar = {
    enable = true;
    systemdTarget = "mango.target";

    settings = {
      layer = "top";
      height = 30;
      "buffer-scale" = 1;

      "modules-left" = [
        "workspaces"
        "layout"
        "window"
      ];
      "modules-center" = [];
      "modules-right" = [
        "network"
        "cpu"
        "memory"
        "pulseaudio"
        "battery"
        "clock#date"
        "clock#time"
      ];

      workspaces = {
        "hide-empty" = true;
        "overview-label" = "OVERVIEW";
        "on-click" = "activate";
        "on-click-right" = "toggle";
      };

      layout = {
        format = "{}";
      };

      window = {
        format = "{}";
      };

      network = {
        format = "{icon} {ifname}";
        "format-wifi" = "{signal} {ssid}";
        "format-disconnected" = "{icon}";
        "icon-wifi" = "󰖩";
        "icon-ethernet" = "󰈀";
        "icon-disconnected" = "󰖪";
        "signal-icons" = [ "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
        "format-alt" = "↓{down} ↑{up}";
      };

      cpu = {
        format = " {load}%";
      };

      memory = {
        format = " {}%";
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        "on-click" = "${pkgs.pavucontrol}/bin/pavucontrol";
        "format-muted" = "󰖁 muted";
        "on-scroll-up" = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "on-scroll-down" = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        icons = [ "󰖁" "󰕿" "󰕾" ];
      };

      battery = {
        format = "{icon} {percent}%";
        icons = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
      };

      "clock#date" = {
        format = "{:%A, %B %d}";
      };

      "clock#time" = {
        format = "{:%I:%M %p}";
      };
    };
  };

  # Nerd Font so icon glyphs render in mangobar.
  home.packages = with pkgs.nerd-fonts; [
    jetbrains-mono
  ];

  # mangobar style.css — sets font-family + base colors.
  xdg.configFile."mangobar/style.css".text = ''
    * {
      font-family: "JetBrainsMono Nerd Font";
      font-size: 16px;
      font-weight: normal;
      color: #cdd6f4;
      background-color: #1e1e2e;
      padding: 0px 10px;
      margin: 4px 1px;
      border-radius: 6px;
    }

    #bar {
      background: none;
      margin: 4px 10px;
    }
    #bar.sel {
      background: none;
    }

    #tags {
      padding: 0px 13px;
      margin: 0px 2px;
    }
    #tags.active {
      background-color: #89b4fa;
      color: #1e1e2e;
    }
    #tags.occupied {
      background-color: #585b70;
      color: #cdd6f4;
    }
    #tags.urgent {
      background-color: #f38ba8;
      color: #1e1e2e;
    }
    #tags.empty {
      background-color: #313244;
      color: #a6adc8;
    }

    #layout {
      background-color: #cba6f7;
      color: #1e1e2e;
      min-width: 34px;
    }

    #title {
      background-color: #cba6f7;
      color: #1e1e2e;
    }

    #clock {
      background-color: #f9e2af;
      color: #1e1e2e;
    }
    #clock.date {
      background-color: #a6e3a1;
      color: #1e1e2e;
    }

    #cpu {
      background-color: #fab387;
      color: #1e1e2e;
    }
    #mem {
      background-color: #89b4fa;
      color: #1e1e2e;
    }

    #volume {
      background-color: #f5c2e7;
      color: #1e1e2e;
    }

    #network {
      background-color: #a6e3a1;
      color: #1e1e2e;
    }
    #network.wifi {
      background-color: #89b4fa;
      color: #1e1e2e;
    }
    #network.ethernet {
      background-color: #a6e3a1;
      color: #1e1e2e;
    }
    #network.disconnected {
      background-color: #f38ba8;
      color: #1e1e2e;
    }

    #battery {
      background-color: #f9e2af;
      color: #1e1e2e;
    }

    #tray {
      background-color: #45475a;
      padding: 0px 12px;
    }
  '';
}
