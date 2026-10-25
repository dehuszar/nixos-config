# modules/home/wallust.nix
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
    inputs.wallust.packages.${pkgs.system}.wallust
  ];

  # Symlink wallust.toml → ~/.config/wallust/wallust.toml
  home.activation.wallust-config = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ln -sfT "$HOME/nix/nixos-config/modules/home/wallust" "$HOME/.config/wallust"
  '';
}
