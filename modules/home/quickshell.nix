# modules/home/quickshell.nix
#
# Home Manager configuration for QuickShell compositor.
# Manages the quickshell program and its configuration files.
{ config, pkgs, ... }:
let
  # Define your QuickShell config directories
  # Each should contain qml files, css files, etc.
  quickshellDefaultConfig = ./quickshell-configs/default;
in
{
  # Enable QuickShell program through home-manager
  programs.quickshell = {
    enable = true;

    # Enable systemd integration for proper session management
    systemd.enable = true;
    configs = {
      default = quickshellDefaultConfig;
    };

    # Add any additional quickshell-specific options here
    # For example, if there are package overrides or extra settings

    # If you need to add custom packages that quickshell depends on:
    # extraPackages = [
    #   pkgs.some-dependency
    # ];
  };

  # If QuickShell needs configuration files in ~/.config/quickshell/,
  # you can manage them with xdg.configFile:
  #
  # xdg.configFile."quickshell/config.qml".source = ./quickshell-config/config.qml;
  # xdg.configFile."quickshell/theme.css".source = ./quickshell-config/theme.css;
}
