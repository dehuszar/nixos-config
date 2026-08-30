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
          extraModules = [ ./vm-root.nix ];
        };
      };
    };
}