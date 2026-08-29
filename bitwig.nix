# bitwig.nix
{ pkgs, ... }:
let
  bitwig-studio-beta = pkgs.bitwig-studio.overrideAttrs (
    finalAttrs: prevAttrs: {
      version = "6.1-beta-6";
      src = pkgs.fetchurl {
        name = "bitwig-studio-${finalAttrs.version}.deb";
        url = "https://www.bitwig.com/dl/Bitwig%20Studio/6.1%20Beta%206/installer_linux/";
        hash = "sha256-XiC6OO9TsZkENdLxOr3jGdhVdiszvZ0ziSDFMBaPZcA=";
      };
    }
  );
  bottles-overridden = pkgs.bottles.override { removeWarningPopup = true; };
in
{
  home.packages = [
    bitwig-studio-beta
    bottles-overridden
    pkgs.yabridge
    pkgs.yabridgectl
  ];
}
