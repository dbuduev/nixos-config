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
      hurl
      wget
      ripgrep
      fd
      jq # A lightweight and flexible command-line JSON processor
      yq-go # yaml processor https://github.com/mikefarah/yq
      eza # A modern replacement for ‘ls’
      bat
      ed

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
      topgrade
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
      # Markdown
      marksman # LSP
    ]
    ++ (with unstable-pkgs; [
      # Go
      gopls
      gops
      gotestsum

      # Rust
      rustup

      bazelisk

      # Zig
      zig
      zls

      lldb
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
      golang.disabled = true;
      buf.disabled = true;
      nodejs.disabled = true;
      rust.disabled = true;
      package.disabled = true;
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
      theme = "catppuccin_frappe";
      editor = {
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
        file-picker.hidden = false;
        file-picker.git-ignore = false;
        soft-wrap.enable = true;
      };
    };
    languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = "alejandra";
      }
      {
        name = "zig";
        auto-format = true;
      }
    ];
  };

  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    keyMode = "vi";
    extraConfig = ''
      # vi copy mode improvements
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      bind-key -T copy-mode-vi r send-keys -X rectangle-toggle

      # Use v to trigger selection
      # Use y to yank current selection
      # Search with / just like in vim

      # Add visual indication of copy mode and selection
      set-window-option -g mode-style bg=colour4,fg=colour0

      set -sg escape-time 10

      # New windows will inherit current path
      bind c new-window -c "#{pane_current_path}"

      # Styling
      set -g clock-mode-style 24
      set -g copy-mode-current-match-style bg=#89ca78,fg=#282C34
      set -g copy-mode-mark-style bg=#ffffff,fg=#282C34
      set -g copy-mode-match-style bg=#ffffff,fg=#282C34
      set -g cursor-style blinking-block
      set -g message-command-style bg=#22252C,fg=#abb2bf
      set -g message-style bg=#22252C,fg=#abb2bf
      set -g mode-style bg=#89ca78,fg=#282C34
      set -g pane-active-border-style bg=#282C34,fg=#89ca78,bold
      set -g pane-border-format "#{pane_index} #{pane_current_command} (#{pane_pid})"
      set -g pane-border-indicators colour
      set -g pane-border-lines heavy
      set -g pane-border-status top
      set -g pane-border-style bg="#282C34"
      set -g status-justify left
      set -g status-left-length 20
      set -g status-left "#{?session_grouped,#[bg=#61afef fg=#000000] #{session_group} #[bg=#d55fde fg=#61afef],}#[bg=#d55fde fg=#000000] #S#[noitalics] #[bg=#22252C fg=#d55fde]"
      set -g status-position bottom
      set -g status-right "#[bg=#22252C fg=#be5046]#[bg=#be5046 fg=#000000] #H #[bg=#be5046 fg=#d19a66]#[bg=#d19a66 fg=#000000] #(date +%Y-%m-%d) #[bg=#d19a66 fg=#e5c07b]#[bg=#e5c07b fg=#000000] #(date +%H:%M) "
      set -g status-style bg=#22252C,fg=#000000
      set -g window-status-activity-style noreverse,bold
      set -g window-status-bell-style noreverse,bold
      set -g window-status-current-format " #I:#W#F "
      set -g window-status-current-style fg=#89ca78,bold
      set -g window-status-format " #I:#W#F "
      set -g window-status-style fg=#abb2bf
      set -g window-status-last-style fg=#2bbac5,bold
      set -g window-status-separator "#[bg=#22252C fg=#abb2bf]"
      set -g window-style bg=#282C34

    '';
  };

  programs.navi = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      cheats = {
        paths = ["${config.home.homeDirectory}/.local/share/navi/cheats"];
      };
      finder = {
        command = "fzf";
      };
      shell = {
        command = "zsh";
      };
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  home.file.".local/share/navi/cheats" = {
    source = ./navi/cheats;
    recursive = true;
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
    NIX_LD = "$(cat ${pkgs.stdenv.cc}/nix-support/dynamic-linker)";
  };

  home.sessionPath = ["$HOME/.cargo/bin"];
  dconf.settings = {
    "org/gnome/desktop/wm/keybindings" = {
      # disable Alt-` (backtick) shortcut for switching between windows of the same application
      "switch-group" = [];

      # disable the related shortcuts:
      "switch-group-backward" = [];
    };
    "org/gnome/desktop/input-sources" = {
      xkb-options = ["caps:escape"];
    };
  };
}
