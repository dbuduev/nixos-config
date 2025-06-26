{
  description = "FHS development environment for Go projects";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs }:
    let
      system = "aarch64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      # Properly define the devShell
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [ 
          # This builds the FHS environment and makes it available as a package
          (pkgs.buildFHSUserEnv {
            name = "go-fhs-env";
            targetPkgs = pkgs: with pkgs; [
              stdenv.cc.cc.lib
              glibc
            ];
            profile = ''
              export PATH="$PATH"
              export GOPATH="$HOME/go"
            '';
            runScript = "bash";
          })
        ];
        
        # Add a helpful shell hook
        shellHook = ''
          echo "FHS environment available. Run 'go-fhs-env' to enter it."
        '';
      };
    };
}
