{
  pkgs,
  unstable-pkgs,
  ...
}: {
  home.username = "coder";
  home.homeDirectory = "/home/coder";
  home.stateVersion = "24.11";

  home.packages = [
    # Pinned ahead of nixpkgs for Fable 5.2 (needs >= 2.1.321); drop override when nixpkgs catches up
    (unstable-pkgs.claude-code.override {
      manifest = builtins.fromJSON (builtins.readFile ./claude-code-manifest.json);
    })
    pkgs.git
  ];

  home.sessionVariables = {
    DOCKER_HOST = "unix://\${XDG_RUNTIME_DIR}/podman/podman.sock";
  };
}
