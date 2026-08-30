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
    in
    {
      nixosConfigurations = {
        hostname = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.sam = ./home.nix;
            }
            mangowm.nixosModules.mango
          ];
        };
      };
    };
}
