{
  description = "Koka development shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
  in {
    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          koka
          # Koka compiles to C; these are needed for `koka -e` / `koka -c`
          gcc
          cmake
          gnumake
          ninja
          pkg-config
        ];

        shellHook = ''
          echo "koka $(koka --version | head -n1 | cut -d' ' -f2)"
          echo "run:  koka -e hello.kk"
          echo "repl: koka"
        '';
      };
    });

    formatter = forAllSystems (pkgs: pkgs.alejandra);
  };
}
