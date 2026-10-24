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
    $DRY_RUN_CMD mkdir -p "$HOME/.config/wallust"
    $DRY_RUN_CMD ln -sf "$HOME/nix/nixos-config/modules/home/wallust.toml" "$HOME/.config/wallust/wallust.toml"
  '';
}
