# home.nix
#
# Home Manager entry point for user `sam`: identity, the shared package set,
# and misc program config. Desktop (mangowm) and VM concerns live under
# modules/home/ and are imported below.
{ pkgs, ... }:

{
  imports = [
    ./bitwig.nix
    ./modules/home/mango.nix
    ./modules/home/vm-resize.nix
  ];

  home.username = "sam";
  home.homeDirectory = "/home/sam";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes. Do not change it; check the
  # release notes when updating.
  home.stateVersion = "26.11";

  home.packages = with pkgs; [
    # 3D Slicers from nixpkgs 26.05
    blender
    cura-appimage
    dbeaver-bin
    docker-sbx
    firefox
    ghostty
    freecad
    gimp
    inkscape
    libation
    noto-fonts
    openscad
    orca-slicer
    proton-authenticator
    proton-pass
    proton-pass-cli
    proton-vpn
    proton-vpn-cli
    protonmail-desktop
    # steam
    thorium-reader
    yazi
  ];

  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    SUDO_EDITOR = "nvim";
  };

  programs.home-manager.enable = true;
  # pi-coding-agent appears to be on the unstable branch, not the current 26.05
  programs.pi-coding-agent.enable = true;

  targets.genericLinux.enable = true;
  targets.genericLinux.gpu.enable = true;
}
