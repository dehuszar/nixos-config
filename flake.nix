{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    mangowm = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      mangowm,
      ...
    }:
    let
      inherit (nixpkgs) lib;

      # Shared module list for every machine. `isVM` is injected via
      # specialArgs so each config can flip VM-only workarounds.
      mkNixos =
        { system ? "x86_64-linux", isVM ? false, extraModules ? [ ] }:
        lib.nixosSystem {
          inherit system;
          specialArgs = { inherit isVM; };
          modules = [
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs isVM;
              };
              home-manager.users.sam = ./home.nix;
            }
            mangowm.nixosModules.mango
          ] ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        # Real hardware (this machine / bootstrap target): no VM workarounds.
        # Imports the placeholder hardware config (template root filesystem).
        hostname = mkNixos {
          isVM = false;
          extraModules = [ ./hardware-configuration.nix ];
        };

        # Test VM: carries software-render + legacy-KMS workarounds so
        # mangowm can run under QEMU's GPU-less display.
        # Build with:  nix build .#nixosConfigurations.vm.config.system.build.vm
        vm = mkNixos {
          isVM = true;
          extraModules = [
            ./vm-root.nix
            # The VM option namespace (`virtualisation.qemu.*`, incl. the
            # `options` list and `package` used for the display adapter) and
            # the `system.build.vm` runner are provided by qemu-vm.nix. Since
            # the nixpkgs bump to 26.11, qemu-vm.nix is no longer part of the
            # default module-list (it only appears under
            # `documentation.nixos.extraModules`), so it must be imported
            # explicitly here or `virtualisation.qemu.options` won't be declared
            # and the build fails with "option does not exist".
            #
            # NOTE: this display config must live in a VM-only module (NOT the
            # shared configuration.nix), because the real-hardware config
            # doesn't import qemu-vm.nix — defining `virtualisation.qemu.*`
            # there breaks the hostname build even when `isVM = false`.
            "${nixpkgs.outPath}/nixos/modules/virtualisation/qemu-vm.nix"
            # Make mangowm actually visible in QEMU: replace the default bochs
            # std VGA adapter with a single virtio-gpu that has virgl (host 3D)
            # accel enabled. `-vga none` drops bochs so there's exactly one
            # output (laying a second device on top is what broke the earlier
            # attempt). `-display gtk,gl=on` gives the window a GL context.
            {
              virtualisation.graphics = true; # a GTK window opens (no -nographic)
              virtualisation.qemu.options = [
                "-vga" "none"
                # Virgl device is a SEPARATE type: `virtio-vga-gl` (NOT
                # `virtio-gpu-pci,gl=on`, which has no `gl` property on QEMU
                # 11.1 -> "Property 'virtio-gpu-pci.gl' not found"). It needs a
                # GL-capable display active, so keep this order.
                "-display" "gtk,gl=on"
                "-device" "virtio-vga-gl"
              ];
            }
          ];
        };
      };
    };
}