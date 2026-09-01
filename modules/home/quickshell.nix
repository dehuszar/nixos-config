# modules/home/quickshell.nix
#
# Home Manager configuration for QuickShell compositor.
# Manages the quickshell program and its configuration files.
#
# LEARNING MODE: Change 'activeExample' to switch between different configs
# Start with "default" (minimal), then progress through examples as you learn.
{ config, pkgs, ... }:
let
  # Choose which example to use - change this as you progress!
  #
  # PROGRESSIVE LEARNING PATH:
  #   "minimal"          - Just workspaces & clock (start here!)
  #   "basic"            - Essential desktop functionality
  #   "intermediate"     - Real system integration (MangoWM, battery, volume)
  #   "maximal"          - Full ekremx25 feature set (advanced)
  #
  # THEMED VARIATIONS:
  #   "catppuccin"       - Catppuccin Mocha theme
  #   "macos"            - macOS-inspired design
  #   "windows11"        - Windows 11 taskbar style
  #   "gnome"            - GNOME top bar aesthetic
  #   "default"          - Your original simple config
  #   "transparency-blur" - Transparency effects (Qt6 fixed)
  activeExample = "maximal";

  # All available configs
  configs = {
    # Learning path
    minimal = ./quickshell-configs/minimal;
    basic = ./quickshell-configs/basic;
    intermediate = ./quickshell-configs/intermediate;
    maximal = ./quickshell-configs/maximal;

    # Themed variations
    catppuccin = ./quickshell-configs/catppuccin;
    macos = ./quickshell-configs/macos;
    windows11 = ./quickshell-configs/windows11;
    gnome = ./quickshell-configs/gnome;

    # Original configs
    default = ./quickshell-configs/default;
    transparency-blur = ./quickshell-configs/026-transparency-blur;
  };
in
{
  # Enable QuickShell program through home-manager
  programs.quickshell = {
    enable = true;

    # Enable systemd integration for proper session management
    # Set to false while learning/testing to avoid conflicts
    systemd.enable = false;

    configs = {
      default = configs.${activeExample};
    };

    # If you need to add custom packages that quickshell depends on:
    # extraPackages = [
    #   pkgs.some-dependency
    # ];
  };
}
