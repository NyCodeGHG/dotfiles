{ pkgs, config, lib, inputs, ... }:
{
  imports = with inputs; [
    home-manager-unstable.nixosModules.default
    ./hardware.nix
    ./nvidia.nix
    ./gaming.nix
    (nixpkgs-libvirt + "/nixos/modules/virtualisation/libvirtd.nix")
  ];
  disabledModules = [
    "virtualisation/libvirtd.nix"
  ];

  programs.direnv.enable = true;

  nixpkgs.config.allowUnfreePredicate = pkg: (builtins.elem (lib.getName pkg) [
    "nvidia-x11"
    "nvidia-settings"
    "nvidia-persistenced"
    "steam"
    "steam-original"
    "steam-run"
    "spotify"
    "corefonts"
    "libnvjitlink"
    "libnpp"
  ]) || (lib.strings.hasInfix "cuda" (lib.getName pkg)) || (lib.strings.hasInfix "libcu" (lib.getName pkg));

  boot.kernelPackages = pkgs.linuxPackages_zen;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  networking = {
    hostName = "marie-desktop";
    networkmanager.enable = true;
    useDHCP = false;
  };
  console = {
    font = "Lat2-Terminus16";
  };
  services = {
    displayManager = {
      sddm = {
        enable = true;
      };
      defaultSession = "plasmax11";
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
  };

  services.pipewire = {
    enable = true;
    jack.enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

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
      options = [ "rw" "uid=1000" "gid=100" "fmask=0077" "dmask=0077" "exec" ];
    };
    "/mnt/other" = {
      device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S6P7NG0RA26626F-part2";
      fsType = "ntfs-3g";
      options = [ "rw" "uid=1000" "gid=100" "fmask=0077" "dmask=0077" "exec" ];
    };
  };

  environment.systemPackages = with pkgs; [
    firefox
    chromium
    vesktop
    spotify
    qpwgraph
    jetbrains.idea-community
    vscodium
    # (inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.nixvim)
    nvtopPackages.nvidia
    whois
    element-desktop
    signal-desktop
    ladybird
    hyfetch
    bat
    tokei
    ripgrep
    virt-manager
    nix-output-monitor
    obs-studio
    vlc
    ffmpeg
    alsa-utils
    nixpkgs-review
    restic
    rclone
  ] ++ (with pkgs.kdePackages;[
    kcalc
  ]);

  environment.sessionVariables = {
    "SSH_ASKPASS_REQUIRE" = "prefer";
    "PAGER" = "${pkgs.less}/bin/less -FRX";
    "EDITOR" = "nvim";
  };

  environment.shellAliases = {
    "vim" = "nvim";
  };

  programs.ssh = {
    enableAskPassword = true;
    askPassword = lib.getExe pkgs.kdePackages.ksshaskpass;
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.podman.enable = true;

  fonts.packages = with pkgs; [
    corefonts
    noto-fonts
    noto-fonts-cjk
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

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "24.05";
}
