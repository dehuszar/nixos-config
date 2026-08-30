{
  config,
  lib,
  pkgs,
  ...
}:
{
  # =========================================================================
  # PLACEHOLDER hardware configuration for the `hostname` (real hardware)
  # NixOS configuration.
  #
  # Replace this whole file with the output of:
  #     nixos-generate-config --root /mnt
  # run on the actual target machine. That generator emits the REAL
  # fileSystems (with device/UUID), swap, CPU/firmware, network interfaces,
  # and GPU options for your hardware.
  #
  # For now a tmpfs root is used only so this config *evaluates* (NixOS
  # requires a root fileSystem to be declared). It does not reflect the real
  # disk layout and is NOT meant to be installed as-is.
  # =========================================================================
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "mode=755" ];
  };
}