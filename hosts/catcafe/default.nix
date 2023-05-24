{ config
, lib
, pkgs
, inputs
, ...
}: {
  imports = [
    ./hardware.nix
    ../../modules/nix-config.nix
    ../../modules/fonts.nix
  ];
  # services.mullvad-vpn.enable = true;
  programs.steam.enable = true;
  virtualisation.libvirtd.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking = {
    hostName = "catcafe"; # Define your hostname.
    networkmanager = {
      enable = true;
      firewallBackend = "nftables";
    };
    firewall = {
      enable = true;
    };
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
  };

  boot.kernelModules = [ "88x2bu" ];
  boot.extraModulePackages = [
    config.boot.kernelPackages.rtl88x2bu
  ];
  boot.blacklistedKernelModules = [
    "ath9k"
  ];

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  services.xserver = {
    layout = "de";
    xkbVariant = "";
  };

  console.keyMap = "de";
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = [ pkgs.vim pkgs.openssl ];
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
  # virtualisation.docker.enable = true;
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  programs.ssh = {
    startAgent = true;
    extraConfig = ''
      AddKeysToAgent  yes
    '';
  };
  programs.zsh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      # intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
    driSupport32Bit = true;
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  hardware.sane.enable = true;
  services.avahi = {
    enable = true;
  };

  hardware.cpu.intel.updateMicrocode = true;
  powerManagement.cpuFreqGovernor = "powersave";
}
