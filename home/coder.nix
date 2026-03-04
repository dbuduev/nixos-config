{pkgs, ...}: {
  home.username = "coder";
  home.homeDirectory = "/home/coder";
  home.stateVersion = "24.11";

  programs.git = {
    enable = true;
    includes = [
      {
        condition = "gitdir:/home/shared/projects/cerbos-org/";
        path = "/home/shared/projects/cerbos-org/.gitconfig";
      }
    ];
  };

  home.sessionVariables = {
    DOCKER_HOST = "unix://\${XDG_RUNTIME_DIR}/podman/podman.sock";
  };
}
