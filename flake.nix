{
  description = "NixOS flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    ...
  } @ inputs: let
    mkSystem = {
      system,
      hostName,
      extraModules ? [],
    }: let
      unstable-pkgs = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit unstable-pkgs;};
        modules =
          [
            ./hosts/${hostName}/configuration.nix
            ./hosts/${hostName}/hardware-configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {inherit unstable-pkgs;};
              home-manager.users.dennisb = import ./home/home.nix;
              home-manager.backupFileExtension = "backup";
            }
          ]
          ++ extraModules;
      };
  in {
    nixosConfigurations = {
      # VMware VM (ARM64)
      my-nixos = mkSystem {
        system = "aarch64-linux";
        hostName = "vm";
      };

      # Zenbook S16 (x86_64)
      zenbook = mkSystem {
        system = "x86_64-linux";
        hostName = "zenbook";
      };
    };
  };
}
