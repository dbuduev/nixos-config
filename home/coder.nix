{pkgs, ...}: {
  home.username = "coder";
  home.homeDirectory = "/home/coder";
  home.stateVersion = "24.11";

  home.sessionVariables = {
    DOCKER_HOST = "unix://\${XDG_RUNTIME_DIR}/podman/podman.sock";
  };
}
