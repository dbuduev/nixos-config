{
  config,
  pkgs,
  unstable-pkgs,
  ...
}: {
  home.username = "dennisb";
  home.homeDirectory = "/home/dennisb";

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # Packages that should be installed to the user profile.
  home.packages = with pkgs;
    [
      #      home-manager

      nnn # terminal file manager

      # archives
      zip
      xz
      unzip
      p7zip
      zstd

      # utils
      curl
      wget
      ripgrep
      fd
      jq # A lightweight and flexible command-line JSON processor
      yq-go # yaml processor https://github.com/mikefarah/yq
      eza # A modern replacement for ‘ls’
      bat

      # networking tools
      mtr # A network diagnostic tool
      iperf3
      dnsutils # `dig` + `nslookup`
      ldns # replacement of `dig`, it provide the command `drill`
      aria2 # A lightweight multi-protocol & multi-source command-line download utility
      socat # replacement of openbsd-netcat
      nmap # A utility for network discovery and security auditing
      ipcalc # it is a calculator for the IPv4/v6 addresses

      # misc
      file
      which
      tree
      gnused
      gnutar
      gawk
      gnupg

      # nix related
      #
      # it provides the command `nom` works just like `nix`
      # with more details log output
      nix-output-monitor
      alejandra

      btop # replacement of htop/nmon
      iotop # io monitoring
      iftop # network monitoring

      # system call monitoring
      strace # system call monitoring
      ltrace # library call monitoring
      lsof # list open files

      # system tools
      sysstat
      lm_sensors # for `sensors` command
      ethtool
      pciutils # lspci
      usbutils # lsusb

      # vcs
      git-credential-manager

      # dev-tools
      just
      gcc
      lazygit
      #
      # image and document rendering
      imagemagick # 'magick' and 'convert' commands
      ghostscript # 'gs' command
      tectonic # LaTeX rendering

      # Mermaid diagrams
      mermaid-cli # For 'mmdc' command
    ]
    ++ (with unstable-pkgs; [
      # Go
      gopls
      gops
      gotestsum

      # Rust
      rustup
    ]);

  programs.git = {
    enable = true;
    lfs.enable = true;
    package = pkgs.git.override {withLibsecret = true;};
    userName = "Dennis Buduev";
    userEmail = "dbuduev@users.noreply.github.com";

    extraConfig = {
      credential.helper = "libsecret";
      credential."https://github.com".username = "dbuduev";
      credential.credentialStore = "secretservice";

      #dasf
      commit.signoff = true;
      commit.gpgsign = false;
    };

    aliases = {
      ci = "commit";
      st = "status";
      df = "diff";
      co = "checkout";
    };
  };

  programs.gh = {
    enable = true;
  };

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    # custom settings
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "rg --files";
    defaultOptions = [
      "--layout=reverse"
      "--info=inline"
      "--height=80%"
      "--multi"
      "--preview-window=:hidden"
      "--preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'"
      "--bind '?:toggle-preview'"
    ];
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = false;
    enableCompletion = true;
    enableVteIntegration = true;
    envExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
      export PAGER=bat
      export LESS='-F -g -i -M -R -S -w -X -z-4'
      export EDITOR=vim
    '';
    autocd = true;
    cdpath = ["/home/dennisb/projects"];
    defaultKeymap = "emacs";
    history = {
      expireDuplicatesFirst = true;
      extended = true;
      ignoreDups = true;
      ignoreSpace = true;
      save = 100000;
      size = 100000;
    };

    historySubstringSearch = {
      enable = true;
      searchUpKey = "^[[A";
      searchDownKey = "^[[B";
    };

    syntaxHighlighting = {
      enable = true;
    };
    initExtraFirst = ''
      autoload edit-command-line
      zle -N edit-command-line
      bindkey '^x^e' edit-command-line

      function delete-branches() {
        git branch |
          grep --invert-match '\*' |
          cut -c 3- |
          fzf --multi --preview="git log {}" |
          xargs --no-run-if-empty git branch --delete --force
      }

      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
    '';
    initExtra = ''
      autoload -Uz bracketed-paste-magic
      zle -N bracketed-paste bracketed-paste-magic

      bindkey "$terminfo[kcuu1]" history-substring-search-up
      bindkey "$terminfo[kcud1]" history-substring-search-down
    '';
    shellAliases = {
      k = "kubectl";
      ll = "ls -lh";
      la = "ls -lAh";
      lg = "lazygit";
    };
    zplug = {
      enable = true;
      plugins = [
        {
          name = "Aloxaf/fzf-tab";
        }
        {
          name = "Freed-Wu/fzf-tab-source";
        }
        {
          name = "chisui/zsh-nix-shell";
        }
        {
          name = "zsh-users/zsh-completions";
        }
        {
          name = "zsh-users/zsh-syntax-highlighting";
          tags = [
            "defer:2"
          ];
        }
      ];
    };
  };
  programs.bash.enable = false;

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.go = {
    enable = true;
    goBin = ".local/bin";
    package = unstable-pkgs.go_1_24;
  };

  programs.helix = {
    enable = true;
    settings = {
      editor.cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "underline";
      };
      editor.file-picker.hidden = false;
      editor.file-picker.git-ignore = false;
    };
    languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = "alejandra";
      }
    ];
  };

  home.file.".config/lazygit/config.yml" = {
    source = ./lazygit/config/config.yml;
  };

  home.file.".config/ghostty/config" = {
    source = ./ghostty/config;
  };

  home.sessionVariables = {
    RUSTUP_HOME = "${config.home.homeDirectory}/.rustup";
    CARGO_HOME = "${config.home.homeDirectory}/.cargo";
    DOCKER_HOST = "unix:///run/podman/podman.sock";
  };

  home.sessionPath = ["$HOME/.cargo/bin"];
  dconf.settings = {
    "org/gnome/desktop/wm/keybindings" = {
      # disable Alt-` (backtick) shortcut for switching between windows of the same application
      "switch-group" = [];

      # disable the related shortcuts:
      "switch-group-backward" = [];
    };
  };
}
