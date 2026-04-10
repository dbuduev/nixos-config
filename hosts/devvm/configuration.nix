# QEMU dev VM — headless sandbox with SSH access.
# Built with: nixos-rebuild build-vm --flake .#devvm
# Shares home-manager dev tooling via the flake's mkSystem helper.
{
  config,
  lib,
  pkgs,
  unstable-pkgs,
  ...
}: let
  sharedIds = import ../../shared-ids.nix;
in {
  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "devvm";
  networking.networkmanager.enable = true;

  # Locale
  time.timeZone = "Australia/Melbourne";
  i18n.defaultLocale = "en_AU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  # Users
  users.groups.devs.gid = sharedIds.devsGid;

  users.users.dennisb = {
    isNormalUser = true;
    uid = sharedIds.dennisbUid;
    description = "dennisb";
    extraGroups = ["networkmanager" "wheel" "podman" "devs"];
    shell = pkgs.zsh;
    initialPassword = "changeme";
  };

  users.users.coder = {
    isNormalUser = true;
    description = "coder";
    extraGroups = ["devs" "podman"];
  };

  # SSH access from host
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true; # for initial setup; switch to keys later
    };
  };

  # Shell & packages
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    curl
    wget
    ripgrep
    fd
    ghostty.terminfo

    # containers
    dive
    podman-tui
    docker-compose
  ];

  # Containers
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings = {
      dns_enabled = true;
      ipv6_enabled = true;
    };
  };

  # QEMU VM settings (used by nixos-rebuild build-vm)
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 8192;
      cores = 4;
      diskSize = 40960;
      forwardPorts = [
        {
          from = "host";
          host.port = 2222;
          guest.port = 22;
        }
      ];
      sharedDirectories = {
        projects = {
          source = "/home/dennisb/projects";
          target = "/home/dennisb/projects";
        };
      };
    };
  };

  # Nix settings
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      glibc
      zlib
      openssl
    ];
  };

  services.timesyncd.enable = lib.mkDefault true;

  system.stateVersion = "24.11";
}
