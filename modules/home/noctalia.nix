# modules/home/noctalia.nix
#
# Home Manager configuration for Noctalia shell.
# Provides a sleek, customizable desktop shell for Wayland compositors.
# Replaces quickshell as the shell layer around MangoWM.
{ inputs, ... }:
{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia = {
    enable = true;

    # Enable systemd integration for proper session management
    systemd.enable = true;

    # Basic configuration - customize as needed
    settings = {
      shell = {
        font = "JetBrainsMono Nerd Font";
        settings_show_advanced = true;
      };

      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
      };
    };
  };
}
