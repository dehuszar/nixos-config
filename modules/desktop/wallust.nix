# modules/desktop/wallust.nix
#
# wallust — generate color palettes from wallpapers.
# Better pywal replacement.
{
  inputs,
  pkgs,
  lib,
  ...
}:

{
  # Install wallust from its flake.
  home.packages = [
    pkgs.wallust
  ];

  # Symlink wallust.toml → ~/.config/wallust/wallust.toml
  home.activation.wallust-config = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ln -sfT "$HOME/nix/nixos-config/modules/desktop/wallust" "$HOME/.config/wallust"
  '';
}
