# modules/disko.nix
#
# Declarative disk layout for the real-hardware NixOS configuration.
# Replaces the nixos-generate-config / hardware-configuration.nix workflow
# so the repo stays portable and the VM needs no git-tree changes.
#
# Layout (GPT):
#   - 512 MiB ESP  → vfat /boot
#   - Remainder    → LUKS container "crypted" → ext4 /
#
# Install from the NixOS minimal installer:
#   sudo nix run github:nix-community/disko/latest#disko-install -- \
#     --flake .#hostname --disk main /dev/nvme0n1
#
# The LUKS password is asked interactively by disko-install during formatting
# and again by the NixOS initrd at every boot.
{ lib, ... }:

{
  # Kernel modules the initrd needs to see the disk controller.
  # nixos-generate-config usually emits these; we add the common ones
  # explicitly so hardware-configuration.nix is no longer required.
  boot.initrd.availableKernelModules = [
    "nvme"
    "ahci"
    "sd_mod"
    "usb_storage"
  ];

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        # Placeholder — overridden by the --disk flag of disko-install.
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                # Interactive password (prompted by disko-install when
                # formatting and by the NixOS initrd at boot).
                # No keyfile is configured; leave askPassword at its default.
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };
  };
}
