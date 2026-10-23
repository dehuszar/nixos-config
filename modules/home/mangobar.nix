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
      };

      battery = {
        format = "{icon} {capacity}%";
        icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
      };

      "clock#date" = {
        format = "{:%A, %B %d}";
      };

      "clock#time" = {
        format = "{:%I:%M %p}";
      };
    };
  };
}
