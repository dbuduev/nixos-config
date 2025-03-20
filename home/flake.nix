{
  description = "Home Manager configuration for Dennis Buduev";

  inputs = {
    # Specify the source of Home Manager and nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixpkgs-unstable,
    ...
  }: let
    # Systems supported
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

    # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    # Nixpkgs instantiated for each supported system
    nixpkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });

    # Unstable nixpkgs instantiated for each supported system
    unstablePkgsFor = forAllSystems (system:
      import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      });
  in {
    homeConfigurations = {
      "arm" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgsFor."aarch64-linux";
        extraSpecialArgs = {
          unstable-pkgs = unstablePkgsFor."aarch64-linux";
        };
        modules = [./home.nix];
      };
    };
  };
}
