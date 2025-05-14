{ pkgs, config, lib, inputs, ... }:
{
  imports = with inputs; [
    home-manager-unstable.nixosModules.default
    agenix.nixosModules.default
    ./hardware.nix
    ./gaming.nix
    ./suspend-fix.nix
    ./tailscale.nix
    ./syncthing.nix
    ./wireshark.nix
    ./backup.nix
    ./corsair-thing.nix
    ./router.nix
    ./krisp-patcher.nix
  ];

  uwumarie.profiles = {
    graphical = true;
  };

  programs.nh = {
    enable = true;
    flake = "/home/marie/dotfiles";
  };
  
  services.fwupd.enable = true;

  programs.direnv.enable = true;

  virtualisation.libvirtd.enable = true;
  
  nixpkgs.config.allowUnfreePredicate = pkg: (builtins.elem (lib.getName pkg) [
    "steam"
    "steam-original"
    "steam-run"
    "steam-unwrapped"
    "spotify"
    "corefonts"
    "discord"
    "hplip"
    "makemkv"
    "anydesk"
  ]);

  boot.kernelPackages = pkgs.linuxPackages_6_14;

  boot = {
    plymouth.enable = true;
    consoleLogLevel = 3;
    kernelParams = [ "quiet" ];
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  # hardware.amdgpu.opencl.enable = true;

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
  systemd.network.wait-online.enable = false;
  console = {
    font = "Lat2-Terminus16";
    earlySetup = true;
  };
  services = {
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
      dnsovertls = "opportunistic";
      extraConfig = ''
        MulticastDNS=resolve
      '';
    };
    # mullvad-vpn = {
    #   enable = true;
    #   package = pkgs.mullvad-vpn;
    # };
  };

  systemd.services.cups-browsed.enable = false;

  programs.fish = {
    enable = true;
    useBabelfish = true;
  };
  users.users.marie = {
    shell = pkgs.fish;
    hashedPassword = "$y$j9T$sNg5DYGGsP1H6KIGjT1bZ1$uGpk3HwXHDTsOBT1Q/BpBbCe5Dxu4eKyqIx1RlWbkN1";
    extraGroups = [ "cdrom" "wireshark" ];
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
      device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S6P7NG0RA26626F-part1";
      fsType = "btrfs";
      options = [ "nofail" "nosuid" "compress=zstd" ];
    };
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-pipewire-audio-capture
    ];
  };

  environment.systemPackages = with pkgs; [
    firefox
    thunderbird
    chromium
    (discord.override {
      withOpenASAR = true;
      withVencord = true;
    })
    spotify
    qpwgraph
    vscodium
    nvtopPackages.amd
    whois
    tokei
    nix-output-monitor
    vlc
    (pkgs.hiPrio (pkgs.runCommandNoCC "vlc-desktop-fix" { } ''
      mkdir -p $out/share/applications
      cp ${pkgs.vlc}/share/applications/vlc.desktop $out/share/applications
      sed -i '/X-KDE-Protocols/ s/,smb//' $out/share/applications/vlc.desktop
    ''))
    mpv
    ffmpeg
    nixpkgs-review
    restic
    rclone
    fastfetch
    python3
    btop
    openssl
    yt-dlp
    android-tools
    protontricks
    clang-tools
    nixfmt-rfc-style
    bashInteractive
    dysk
    dogdns
    qbittorrent
    # cemu
    bitwarden
    p7zip
    easyeffects
    fend
    lm_sensors
    gimp3
    man-pages
    unrar-wrapper
    smartmontools
    libreoffice-qt6-fresh
    yq-go
    nushell
    jq
    wl-clipboard-rs
    trashy
    jetbrains.idea-community
    makemkv
    scrcpy
    zfs # to view manpages
    attic-client
    syncthingtray
    quickemu
    anydesk
    ludusavi
    iperf3
    sequoia-sq
    sequoia-chameleon-gnupg
    magic-wormhole
    wireguard-tools
    (chatterino7.overrideAttrs (prev: {
      version = "7.5.3";
      src = prev.src.override {
        hash = "sha256-KrAr3DcQDjb+LP+vIf0qLSSgII0m5rNwhncLNHlLaC8=";
      };

      buildInputs = prev.buildInputs ++ (with pkgs; [
        libnotify
        kdePackages.qtwayland
        kdePackages.qtimageformats
      ]);
    }))
    config.boot.kernelPackages.cpupower
  ] ++ (with pkgs.kdePackages;[
    isoimagewriter
    kdenlive
    partitionmanager
    filelight
    konversation
    sddm-kcm
  ]);

  virtualisation.spiceUSBRedirection.enable = true;

  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [ hplip ];
  };

  environment.sessionVariables = {
    "SSH_ASKPASS_REQUIRE" = "prefer";
    "PAGER" = "${pkgs.less}/bin/less -FRX";
    "EDITOR" = "nvim";
  };

  environment.shellAliases = {
    "vim" = "nvim";
    "ffmpeg" = "ffmpeg -hide_banner";
    "ffprobe" = "ffprobe -hide_banner";
    "ffplay" = "ffplay -hide_banner";
  };
  
  virtualisation.podman.enable = true;

  fonts.packages = with pkgs; [ corefonts ];

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

  programs.nix-ld.enable = true;

  hardware.bluetooth.enable = true;

  nixpkgs.config.permittedInsecurePackages = [
    "jitsi-meet-1.0.8043"
  ];

  users.users.marie.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILCcImzZop8RaAlrAy9HBy6LZz3iOaq9V5tThwIB8Ar4"
    # termux mobile
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAs0W2PBnnSG7LvyE0TnfnFjzaC4tbRludscIZM+SWci"
  ];

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "24.05";
}
