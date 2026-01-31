# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  imports = [
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  # Zenbook specific
  boot.kernelPackages = pkgs.linuxPackages_latest;
  services.xserver.videoDrivers = ["amdgpu"];
  hardware.amdgpu.initrd.enable = true;
  services.power-profiles-daemon.enable = false;
  services.tlp.enable = true;
  services.fwupd.enable = true;

  # Swap options (uncomment as needed)
  # Zram: compressed RAM swap, good for SSDs
  # zramSwap = {
  #   enable = true;
  #   memoryPercent = 50;
  # };
  # Swapfile: required for hibernation (needs >= RAM size)
  # swapDevices = [{
  #   device = "/swapfile";
  #   size = 32768;  # 32GB in MB
  # }];
  # Hibernation resume (if using swapfile on encrypted disk)
  # Get offset: sudo filefrag -v /swapfile | head -4
  # boot.resumeDevice = "/dev/disk/by-uuid/abc09bb6-98a0-468e-ad43-66eb930a048d";
  # boot.kernelParams = [ "resume_offset=<offset>" ];

  # Encryption options (enable if disk is encrypted with LUKS)
  # boot.initrd.luks.devices."cryptroot".allowDiscards = true;  # SSD TRIM support
  # boot.initrd.availableKernelModules = [ "aes_x86_64" "cryptd" ];  # faster crypto
  # boot.plymouth.enable = true;  # nicer password prompt

  networking.hostName = "zenbook"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Australia/Melbourne";

  # Select internationalisation properties.
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
  # Enable graphical display (GDM + GNOME, runs Wayland by default)
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome = {
    enable = true;
    extraGSettingsOverrides = ''
      [org.gnome.desktop.session]
      idle-delay=600
    '';
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dennisb = {
    isNormalUser = true;
    description = "dennisb";
    extraGroups = ["networkmanager" "wheel" "podman"];
    shell = pkgs.zsh;
    packages = with pkgs; [
      # managed by home-manager
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  programs.zsh.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    curl
    wget
    ghostty
    ripgrep
    fd
    wl-clipboard

    # containers
    dive
    podman-tui
    docker-compose
  ];

  fonts.packages = with pkgs; [
    pkgs.nerd-fonts._0xproto
    pkgs.nerd-fonts.droid-sans-mono
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  services.openssh.enable = false;
  # SSH hardening (if enabled)
  # services.openssh.settings = {
  #   PasswordAuthentication = false;
  #   PermitRootLogin = "no";
  #   KbdInteractiveAuthentication = false;
  # };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  services.timesyncd.enable = true;
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;

    # Create a `docker` alias for podman, to use it as a drop-in replacement
    dockerCompat = true;

    # Required for containers under podman-compose to be able to talk to each other.
    defaultNetwork.settings = {
      dns_enabled = true;
      ipv6_enabled = true;
    };
  };

  #console.font = "Lat2-Terminus16";
  console = {
    font = "ter-v32n";
    packages = [pkgs.terminus_font];
  };
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

  services.libinput = {
    enable = true;
    touchpad = {
      disableWhileTyping = true;
      tapping = true;
    };
  };
}
