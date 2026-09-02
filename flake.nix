{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    mangowm = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "github:quickshell-mirror/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- UEFI Secure Boot (lanzaboote) ---
    # Uncomment this input AND the `lanzaboote` ref below (and the
    # boot.lanzaboote block in configuration.nix), then:
    #   nix flake lock ; sudo nixos-rebuild switch --flake .#hostname
    # lanzaboote = {
    #   url = "github:nix-community/lanzaboote";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      mangowm,
      quickshell,
      noctalia,
      # lanzaboote,   # uncomment with the input above for Secure Boot
      ...
    }:
    let
      inherit (nixpkgs) lib;

      # Check for private modules directory in sibling repo
      privateDir = ../nixos-config-private;
      hasPrivate = builtins.pathExists privateDir;
      
      # Auto-load private modules if they exist
      privateModules = if hasPrivate then
        let
          files = builtins.attrNames (builtins.readDir privateDir);
          nixFiles = builtins.filter (f: lib.hasSuffix ".nix" f && f != "default.nix") files;
        in
          map (f: privateDir + "/${f}") nixFiles
      else [];
      
      # Shared module list for every machine. `isVM` is injected via
      # specialArgs so each config can flip VM-only workarounds.
      mkNixos =
        {
          system ? "x86_64-linux",
          isVM ? false,
          extraModules ? [ ],
        }:
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
            # lanzaboote.nixosModules.lanzaboote   # uncomment with the input above for Secure Boot
          ]
          ++ privateModules
          ++ extraModules;
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

        # Test VM: renders mangowm through virtio-gpu/virgl in a QEMU window.
        # All VM-only concerns (qemu-vm import, display adapter, tmpfs root,
        # VM password) live in modules/vm.nix.
        # Build with:  nix build .#nixosConfigurations.vm.config.system.build.vm
        vm = mkNixos {
          isVM = true;
          extraModules = [ ./modules/vm.nix ];
        };
      };
    };
}
