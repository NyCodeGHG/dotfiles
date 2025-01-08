{ pkgs, config, lib, inputs, ... }:
{
  imports = with inputs; [
    home-manager-unstable.nixosModules.default
    ./hardware.nix
    ./gaming.nix
    ./suspend-fix.nix
    ./tailscale.nix
  ];

  uwumarie.profiles = {
    graphical = true;
  };

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
  ]);

  boot.kernelPackages = pkgs.linuxPackages_latest;

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
  console = {
    font = "Lat2-Terminus16";
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
    vesktop
    discord
    spotify
    qpwgraph
    vscodium
    nvtopPackages.amd
    whois
    element-desktop
    bat
    tokei
    ripgrep
    nix-output-monitor
    vlc
    mpv
    ffmpeg
    nixpkgs-review
    restic
    rclone
    fastfetch
    python3
    partclone
    wireguard-tools
    # (btop.override { rocmSupport = true; })
    btop
    openssl
    yt-dlp
    android-tools
    adbfs-rootless
    protontricks
    polychromatic
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
    trashy
    jetbrains.idea-community
  ] ++ (with pkgs.kdePackages;[
    isoimagewriter
    kdenlive
    partitionmanager
    filelight
  ]);

  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [ hplipWithPlugin ];
  };

  environment.sessionVariables = {
    "SSH_ASKPASS_REQUIRE" = "prefer";
    "PAGER" = "${pkgs.less}/bin/less -FRX";
    "EDITOR" = "nvim";
  };

  environment.shellAliases = {
    "vim" = "nvim";
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
  hardware.openrazer = {
    enable = true;
    users = [ "marie" ];
  };
  boot.initrd.kernelModules = [ "razerkbd" "razermouse" ];

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
