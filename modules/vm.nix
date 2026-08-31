# modules/vm.nix
#
# Everything that applies only to the QEMU test VM. Imported exclusively by
# `nixosConfigurations.vm` (extraModules in flake.nix), never by the
# real-hardware build, so nothing here can break `hostname`.
{ modulesPath, lib, ... }:
{
  imports = [
    # qemu-vm.nix declares the `virtualisation.qemu.*` options (including the
    # `options` list used below) and the `system.build.vm` runner. It's no
    # longer part of the default module list on nixpkgs 26.11, so import it
    # explicitly. `modulesPath` is a specialArg NixOS injects for exactly this
    # (`${modulesPath}` points at <nixpkgs>/nixos/modules); `pkgs` can NOT be
    # used here because `imports` is resolved before the fixed point settles.
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];

  # Use GTK display without GL acceleration to avoid cursor rendering bugs.
  # This provides a stable local window with good performance for most tasks.
  # If you need remote access or better graphics, consider Spice (commented below).
  virtualisation.qemu.options = [
    "-vga" "none"
    "-display" "gtk"
    "-device" "virtio-vga"
    "-device" "usb-tablet"  # Better mouse handling
  ];

  # Alternative: Spice for remote desktop access (uncomment to use):
  # virtualisation.qemu.options = [
  #   "-vga" "none"
  #   "-device" "virtio-vga"
  #   "-spice" "port=5900,disable-ticketing=on"
  #   "-device" "usb-tablet"
  # ];

  # Placeholder root filesystem (tmpfs) so `nix flake check` can evaluate
  # `system.build.toplevel` for this config without a real disk layout.
  # qemu-vm.nix overrides fileSystems."/" with the virtual disk image at a
  # higher priority, so this never affects the booted VM.
  fileSystems."/" = lib.mkDefault {
    device = "none";
    fsType = "tmpfs";
    options = [ "mode=755" ];
  };

  # VM-only password for serial/CLI login (`make run-cli`) and SSH. The
  # real-hardware config deliberately ships no password (set one with
  # `passwd` after install). `hashedPassword` avoids NixOS's
  # plaintext-in-config warning.
  users.users.sam.hashedPassword =
    "$6$opensslmixed$XIukNLliTMwtHbFe.cIH.esPnPQcBXcEMUmrffMGRNcEY4lvxthPFZ2h0ChoS88VSVd07EUhUcBnuRHDhZSDF/";
}
