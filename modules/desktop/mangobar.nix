# modules/desktop/mangobar.nix
#
# Home Manager configuration for mangobar — a simple Wayland status bar
# for mangowm.  Config files live in the repo and are symlinked so they
# can be edited in-place without a rebuild.
{
  inputs,
  pkgs,
  lib,
  ...
}:

{
  # -- mangobar --
  services.mangobar = {
    enable = true;
    systemdTarget = "graphical-session.target";
  };

  # Install the service so it starts with the graphical session
  systemd.user.services.mangobar = {
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Nerd Font so icon glyphs render in mangobar.
  home.packages = with pkgs.nerd-fonts; [
    jetbrains-mono
  ];

  # Symlink mangobar config files from the repo into ~/.config/mangobar/.
  # Direct symlinks (bypass the Nix store) so you can edit in-place and
  # reload with `systemctl --user restart mangobar.service`.
  home.activation.mangobar-config = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "$HOME/.config/mangobar"
    $DRY_RUN_CMD ln -sf "$HOME/nix/nixos-config/modules/desktop/mangobar/config.jsonc" "$HOME/.config/mangobar/config.jsonc"
    $DRY_RUN_CMD ln -sf "$HOME/nix/nixos-config/modules/desktop/mangobar/style.css" "$HOME/.config/mangobar/style.css"
    $DRY_RUN_CMD ln -sf "$HOME/nix/nixos-config/modules/desktop/mangobar/network.sh" "$HOME/.config/mangobar/network.sh"
  '';
}
