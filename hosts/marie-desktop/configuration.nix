{ pkgs, config, lib, inputs, ... }:
{
  imports = with inputs; [
    home-manager-unstable.nixosModules.default
    ./hardware.nix
    ./gaming.nix
    ./suspend-fix.nix
  ];

  programs.direnv.enable = true;

  nixpkgs.config.allowUnfreePredicate = pkg: (builtins.elem (lib.getName pkg) [
    "steam"
    "steam-original"
    "steam-run"
    "steam-unwrapped"
    "spotify"
    "corefonts"
  ]);

  boot.kernelPackages = pkgs.linuxPackages_latest;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.amdgpu.opencl.enable = true;

  boot.loader = {
    systemd-boot = {
      enable = true;
      memtest86.enable = true;
    };
    efi.canTouchEfiVariables = true;
  };
  networking = {
    hostName = "marie-desktop";
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
    useDHCP = false;
    firewall.logRefusedConnections = false;
  };
  console = {
    font = "Lat2-Terminus16";
  };
  services = {
    displayManager.sddm = {
      enable = true;
      wayland = {
        enable = true;
        compositor = "kwin";
      };
    };
    desktopManager.plasma6.enable = true;
    xserver.enable = true;
    xserver.xkb.layout = "de";
    libinput.enable = true;
    avahi = {
      enable = true;
      openFirewall = true;
      nssmdns4 = true;
    };
    printing = {
      enable = true;
      drivers = with pkgs; [ hplip ];
    };
    resolved = {
      enable = true;
      extraConfig = ''
        MulticastDNS=resolve
      '';
    };
    mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };
  };

  systemd.services.cups-browsed.enable = false;

  services.pipewire = {
    enable = true;
    jack.enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  
  programs.kdeconnect.enable = true;

  programs.fish.enable = true;
  users.users.marie = {
    shell = pkgs.fish;
    hashedPassword = "$y$j9T$sNg5DYGGsP1H6KIGjT1bZ1$uGpk3HwXHDTsOBT1Q/BpBbCe5Dxu4eKyqIx1RlWbkN1";
  };

  fileSystems = {
    "/".options = [ "compress=zstd" ];
    "/home".options = [ "compress=zstd" ];
    "/nix".options = [ "compress=zstd" "noatime" ];
    "/mnt/sata" = {
      device = "/dev/disk/by-id/ata-Samsung_SSD_870_EVO_2TB_S6PPNX0W301861L-part2";
      fsType = "ntfs-3g";
      options = [ "rw" "uid=1000" "gid=100" "fmask=0077" "dmask=0077" "exec" "nofail" ];
    };
    "/mnt/other" = {
      device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S6P7NG0RA26626F-part2";
      fsType = "ntfs-3g";
      options = [ "rw" "uid=1000" "gid=100" "fmask=0077" "dmask=0077" "exec" "nofail" ];
    };
  };

  environment.systemPackages = with pkgs; [
    firefox
    thunderbird
    chromium
    vesktop
    spotify
    qpwgraph
    vscodium
    # (inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.nixvim)
    nvtopPackages.amd
    whois
    element-desktop
    bat
    tokei
    ripgrep
    virt-manager
    nix-output-monitor
    obs-studio
    vlc
    mpv
    ffmpeg
    alsa-utils
    nixpkgs-review
    restic
    rclone
    fastfetch
    python3
    squashfsTools
    partclone
    wireguard-tools
    (btop.override { rocmSupport = true; })
    openssl
    yt-dlp
    android-tools
    adbfs-rootless
    protontricks
    polychromatic
    deno
    clang-tools
    nixfmt-rfc-style
    bashInteractive
    dysk
    dogdns
    qbittorrent
    # cemu
    bitwarden
    weechat-unwrapped
    p7zip
    easyeffects
    fend
    lm_sensors
    gimp
    man-pages
    unrar-wrapper
    smartmontools
    keepassxc
    libreoffice-qt6-fresh
    yq-go
    nushell
    jq
    wl-clipboard-rs
  ] ++ (with pkgs.kdePackages;[
    kcalc
    isoimagewriter
    kdenlive
    partitionmanager
    kio-gdrive
    kaccounts-integration
    kaccounts-providers
    filelight
  ]);

  nixpkgs.overlays = [(final: prev: {
  })];

  environment.sessionVariables = {
    "SSH_ASKPASS_REQUIRE" = "prefer";
    "PAGER" = "${pkgs.less}/bin/less -FRX";
    "EDITOR" = "nvim";
    "KWIN_X11_FORCE_SOFTWARE_VSYNC" = "1";
    "KWIN_X11_NO_SYNC_TO_VBLANK" = "1";
    "FREETYPE_PROPERTIES" = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
  };

  environment.shellAliases = {
    "vim" = "nvim";
  };

  programs.ssh = {
    enableAskPassword = true;
    askPassword = lib.getExe pkgs.kdePackages.ksshaskpass;
  };
  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
  };
  virtualisation.podman.enable = true;

  fonts.packages = with pkgs; [
    corefonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  home-manager.users.marie = { config, pkgs, ... }: {
    imports = [
     inputs.self.homeManagerModules.config
     ./home.nix
    ];
    home = {
      stateVersion = "24.05";
      username = "marie";
      homeDirectory = "/home/${config.home.username}";
    };
  };
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
  };

  programs.command-not-found.enable = false;
  programs.nix-ld.enable = true;

  hardware.bluetooth.enable = true;
  hardware.openrazer = {
    enable = true;
    users = [ "marie" ];
  };

  nixpkgs.config.permittedInsecurePackages = [
    "jitsi-meet-1.0.8043"
  ];

  users.users.marie.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILCcImzZop8RaAlrAy9HBy6LZz3iOaq9V5tThwIB8Ar4"
    # termux mobile
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAs0W2PBnnSG7LvyE0TnfnFjzaC4tbRludscIZM+SWci"
  ];

  time.hardwareClockInLocalTime = true;

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "24.05";
}
