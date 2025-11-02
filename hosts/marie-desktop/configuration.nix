{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  imports = with inputs; [
    home-manager-unstable.nixosModules.default
    agenix.nixosModules.default
    ./hardware.nix
    ./gaming.nix
    ./suspend-fix.nix
    ./syncthing.nix
    ./wireshark.nix
    ./backup.nix
    ./corsair-thing.nix
    # ./router.nix
    ./krisp-patcher.nix
    ./peacock.nix
    ./networking.nix
  ];

  uwumarie.profiles = {
    graphical = true;
    tools = true;
  };

  boot.binfmt.emulatedSystems = [
    "powerpc-linux"
    "aarch64-linux"
  ];
  boot.binfmt.preferStaticEmulators = true;

  programs.nh = {
    enable = true;
    flake = "/home/marie/dotfiles";
  };

  services.fwupd.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.package = pkgs.lixPackageSets.latest.nix-direnv;
  };

  virtualisation.libvirtd.enable = true;

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    (builtins.elem (lib.getName pkg) [
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
      "unrar"
      "7zz"
      "chromium"
      "chromium-unwrapped"
      "widevine-cdm"
    ]);

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot = {
    plymouth.enable = true;
    consoleLogLevel = 3;
    kernelParams = [ "quiet" ];
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [ pkgs.mesa.opencl ];
  };

  boot.loader = {
    systemd-boot = {
      enable = true;
      memtest86.enable = true;
    };
    efi.canTouchEfiVariables = true;
  };
  console = {
    font = "Lat2-Terminus16";
    earlySetup = true;
  };

  systemd.services.cups-browsed.enable = false;

  programs.fish = {
    enable = true;
    useBabelfish = true;
  };
  users.users.marie = {
    shell = pkgs.fish;
    hashedPassword = "$y$j9T$sNg5DYGGsP1H6KIGjT1bZ1$uGpk3HwXHDTsOBT1Q/BpBbCe5Dxu4eKyqIx1RlWbkN1";
    extraGroups = [
      "cdrom"
      "wireshark"
    ];
  };

  fileSystems = {
    "/".options = [ "compress=zstd" ];
    "/home".options = [ "compress=zstd" ];
    "/nix".options = [
      "compress=zstd"
      "noatime"
    ];
    "/mnt/sata" = {
      device = "/dev/disk/by-id/ata-Samsung_SSD_870_EVO_2TB_S6PPNX0W301861L-part2";
      fsType = "ntfs-3g";
      options = [
        "rw"
        "uid=1000"
        "gid=100"
        "fmask=0077"
        "dmask=0077"
        "exec"
        "nofail"
      ];
    };
    "/mnt/other" = {
      device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S6P7NG0RA26626F-part1";
      fsType = "btrfs";
      options = [
        "nofail"
        "nosuid"
        "compress=zstd"
      ];
    };
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-pipewire-audio-capture
    ];
  };

  programs.firefox.enable = true;
  programs.chromium.enable = true;
  programs.thunderbird.enable = true;

  environment.systemPackages =
    with pkgs;
    [
      (chromium.override { enableWideVine = true; })
      discord
      spotify
      qpwgraph
      vscodium
      nvtopPackages.amd
      tokei
      nix-output-monitor
      vlc
      (lib.hiPrio (
        pkgs.runCommand "vlc-desktop-fix" { } ''
          mkdir -p $out/share/applications
          cp ${pkgs.vlc}/share/applications/vlc.desktop $out/share/applications
          sed -i '/X-KDE-Protocols/ s/,smb//' $out/share/applications/vlc.desktop
        ''
      ))
      mpv
      ffmpeg-full
      lixPackageSets.latest.nixpkgs-review
      (nix-update.override {
        nix = config.nix.package;
        inherit (lixPackageSets.latest) nixpkgs-review;
      })
      restic
      rclone
      fastfetch
      python3
      btop
      openssl
      yt-dlp
      protontricks
      clang-tools
      nixfmt
      bashInteractive
      dysk
      dogdns
      qbittorrent
      # cemu
      bitwarden-desktop
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
      chatterino7
      config.boot.kernelPackages.cpupower
      unrar
      # jellyfin-media-player
      distrobox
      docker-compose # for podman-compose
      nix-tree
      signal-desktop
      sshfs
      obs-cmd
      comma
      kdiff3
    ]
    ++ (with pkgs.kdePackages; [
      isoimagewriter
      kdenlive
      partitionmanager
      filelight
      konversation
      sddm-kcm
      krdc
    ]);

  virtualisation.spiceUSBRedirection.enable = true;

  systemd.oomd.enable = false;

  services.earlyoom = {
    enable = true;
    enableNotifications = true;
    freeMemThreshold = 5;
    reportInterval = 0;
  };

  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [ hplip ];
  };

  services.nixseparatedebuginfod2.enable = true;

  environment.variables = {
    "SSH_ASKPASS_REQUIRE" = "prefer";
    "PAGER" = "${pkgs.less}/bin/less -FRX";
    "EDITOR" = "nvim";
    "RUSTICL_ENABLE" = "radeonsi";
  };

  environment.shellAliases = {
    "vim" = "nvim";
    "ffmpeg" = "ffmpeg -hide_banner";
    "ffprobe" = "ffprobe -hide_banner";
    "ffplay" = "ffplay -hide_banner";
    "whois" = "rdap";
  };

  virtualisation.podman.enable = true;
  virtualisation.containers.containersConf.settings.engine.compose_warning_logs = false;

  fonts.packages = with pkgs; [ corefonts ];

  programs.adb.enable = true;

  home-manager.users.marie =
    { config, pkgs, ... }:
    {
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
