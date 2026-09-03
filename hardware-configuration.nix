{
  config,
  lib,
  pkgs,
  ...
}:
{
  # =========================================================================
  # DEPRECATED — this file is no longer imported by the flake.
  #
  # The real-hardware disk layout has been replaced with a declarative
  # disko configuration in modules/disko.nix (LUKS + ext4).  This file is
  # kept in the repo only as a reference; it will be removed in a future
  # cleanup.
  #
  # If you need to add hardware-specific settings (e.g. extra kernel
  # modules, CPU microcode, GPU drivers), create a private module in
  # ../nixos-config-private/ or edit modules/disko.nix.
  # =========================================================================
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "mode=755" ];
  };
}