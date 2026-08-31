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

  # Open a GTK window (no -nographic).
  virtualisation.graphics = true;

  # Make mangowm actually visible in QEMU: replace the default bochs std VGA
  # with a single virtio-gpu that has virgl (host 3D) accel. `-vga none` drops
  # bochs so there's exactly one output (a second device on top is what broke
  # an earlier attempt). Use the dedicated `virtio-vga-gl` device - NOT
  # `virtio-gpu-pci,gl=on`, which has no `gl` property on QEMU 11.1 and fails
  # with "Property 'virtio-gpu-pci.gl' not found". Keep `-display gtk,gl=on`
  # before the device so a GL-capable display is active.
  virtualisation.qemu.options = [
    "-vga" "none"
    "-display" "gtk,gl=on"
    "-device" "virtio-vga-gl"
  ];

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
