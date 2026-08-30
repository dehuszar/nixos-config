{
  lib,
  ...
}:
{
  # Test-VM placeholder root filesystem.
  #
  # `nix flake check` evaluates `system.build.toplevel` for [every] NixOS
  # configuration. The `vm` config normally has its root defined only by the
  # VM-module variant used when building the VM image, so as a plain config
  # it has no root and toplevel checking fails.
  #
  # This low-precedence (mkDefault) tmpfs root satisfies that check. When you
  # actually build the VM image (`system.build.vm`), the NixOS VM module
  # overrides fileSystems."/" with the virtual disk image (default priority
  # beats mkDefault), so this placeholder never affects the booted VM.
  fileSystems."/" = lib.mkDefault {
    device = "none";
    fsType = "tmpfs";
    options = [ "mode=755" ];
  };
}