# bitwig.nix
{ pkgs, ... }:
let
  bottles-overridden = pkgs.bottles.override { removeWarningPopup = true; };
in
{
  home.packages = [
    bottles-overridden
    pkgs.bitwig-studio
    pkgs.yabridge
    pkgs.yabridgectl
  ];
}
