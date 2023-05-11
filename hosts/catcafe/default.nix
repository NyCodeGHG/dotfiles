{ config
, pkgs
, inputs
, jellyfin
, jellyfin-intro-skipper
, ...
}: {
  imports = [
    ./hardware.nix
    ../../modules/motd.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.kernelPackages = pkgs.linuxPackages_5_15;

  networking.hostName = "catcafe"; # Define your hostname.
  networking.networkmanager.enable = true;
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
  environment.systemPackages = [ pkgs.vim ];
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ 22 25565 ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" "https://uwumarie.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" "uwumarie.cachix.org-1:H6nX8e82pu2GQ8CGU3j1qHTG7QMYzZ15oSBh26XhtVo=" ];
    experimental-features = [ "nix-command" "flakes" ];
  };
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.nixPath = [ "nixpkgs=/etc/channels/nixpkgs" "nixos-config=/etc/nixos/configuration.nix" "/nix/var/nix/profiles/per-user/root/channels" ];
  environment.etc."channels/nixpkgs".source = inputs.nixpkgs.outPath;

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

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    package = jellyfin;
  };

  systemd.services.jellyfin-intro-skipper = {
    wantedBy = [ "jellyfin.service" "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/sh -c '${pkgs.coreutils}/bin/mkdir -p /var/lib/jellyfin/plugins/IntroSkipper && ${pkgs.coreutils}/bin/ln -sf ${jellyfin-intro-skipper}/ConfusedPolarBear.Plugin.IntroSkipper.dll -t /var/lib/jellyfin/plugins/IntroSkipper/ && ${pkgs.coreutils}/bin/ln -sf ${jellyfin-intro-skipper}/ConfusedPolarBear.Plugin.IntroSkipper.pdb -t /var/lib/jellyfin/plugins/IntroSkipper/ && ${pkgs.coreutils}/bin/ln -sf ${jellyfin-intro-skipper}/ConfusedPolarBear.Plugin.IntroSkipper.xml -t /var/lib/jellyfin/plugins/IntroSkipper'";
      ExecStop = "${pkgs.coreutils}/bin/rm -rf /var/lib/jellyfin/plugins/IntroSkipper";
      RemainAfterExit = "yes";
      User = "jellyfin";
      Group = "jellyfin";
    };
  };

  services.motd.enable = true;
}
