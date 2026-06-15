{
  description = "NixOS flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    claude-code.url = "github:sadjow/claude-code-nix";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    claude-code,
    home-manager,
    ...
  } @ inputs: let
    mkSystem = {
      system,
      hostName,
      isHeadless ? false,
      hasCoder ? true, # mb-vm has no `coder` system user
      extraModules ? [],
    }: let
      unstable-pkgs = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
        overlays = [claude-code.overlays.default];
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
              home-manager.extraSpecialArgs = {inherit unstable-pkgs isHeadless;};
              home-manager.users.dennisb = import ./home/home.nix;
              home-manager.backupFileExtension = "backup";
            }
            (nixpkgs.lib.optionalAttrs hasCoder {
              home-manager.users.coder = import ./home/coder.nix;
            })
          ]
          ++ extraModules;
      };
  in {
    nixosConfigurations = {
      # VMware VM (ARM64)
      mb-vm = mkSystem {
        system = "aarch64-linux";
        hostName = "vm";
        hasCoder = false;
      };

      # Zenbook S16 (x86_64)
      zenbook = mkSystem {
        system = "x86_64-linux";
        hostName = "zenbook";
      };

      # QEMU dev VM (x86_64, runs on zenbook)
      devvm = mkSystem {
        system = "x86_64-linux";
        hostName = "devvm";
        isHeadless = true;
      };
    };
  };
}
