{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  imports = with inputs; [
    home-manager.nixosModules.default
    agenix.nixosModules.default
    ../../config/nixos/system/graphical.nix
    ../../config/nixos/applications/tailscale.nix
    ./hardware.nix
    ./gaming.nix
    ./suspend-fix.nix
    ./syncthing.nix
    ./wireshark.nix
    ./backup.nix
    # ./router.nix
    # ./krisp-patcher.nix
    ./peacock.nix
    ./networking.nix
    ./nixbuildnet.nix
    ./harmonia
  ];

  virtualisation.waydroid.enable = true;

  uwumarie.profiles = {
    apps = true;
  };

  uwumarie.agenix.enable = true;

  services.fwupd.enable = true;

  # for sidetone thingy
  hardware.alsa.enablePersistence = true;

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
      "idea"
      "rust-rover"
      "clion"
      "nvim-highlight-colors"
      "vim-jack-in"
      "wildfire.nvim"
      "nvim-vtsls"
    ]);

  boot.kernelPackages = pkgs.linuxPackages_latest;

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

  programs.fish = {
    enable = true;
    useBabelfish = true;
  };
  users.users.marie = {
    shell = pkgs.fish;
    hashedPassword = "$y$j9T$sNg5DYGGsP1H6KIGjT1bZ1$uGpk3HwXHDTsOBT1Q/BpBbCe5Dxu4eKyqIx1RlWbkN1";
    extraGroups = [
      "cdrom"
    ];
  };

  programs.ausweisapp = {
    enable = true;
    openFirewall = true;
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
      fsType = "ntfs";
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
    "/mnt/windows-shared-games" = {
      device = "/dev/disk/by-uuid/75734D662554FA4A";
      fsType = "ntfs";
      options = [
        "nofail"
        "nosuid"
        "uid=1000"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    spotify
    nvtopPackages.amd
    qbittorrent
    p7zip
    unrar-wrapper
    nushell
    # makemkv
    scrcpy
    zfs # to view manpages
    attic-client
    # anydesk
    ludusavi
    chatterino7
    unrar
    plezy
    distrobox
    kdiff3
    evcxr
    incus.client
  ];

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
    "RUSTICL_ENABLE" = "radeonsi";
  };

  virtualisation.podman.enable = true;
  virtualisation.containers.containersConf.settings.engine.compose_warning_logs = false;

  fonts.packages = with pkgs; [ corefonts ];

  home-manager.users.marie =
    { config, ... }:
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

  # programs.nix-ld.enable = true;

  hardware.bluetooth.enable = true;

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "24.05";
}
