{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ../../config/nixos/system/graphical.nix
    ../../config/nixos/applications/tailscale.nix
    inputs.jovian.nixosModules.default
    ./syncthing.nix
  ];

  system.stateVersion = "26.11";

  uwumarie.profiles = {
    zram = false;
    corsair = lib.mkForce false;
    dns = false;
  };

  programs.fish.enable = true;
  users.users.marie = {
    shell = pkgs.fish;
    hashedPassword = "$y$j9T$sNg5DYGGsP1H6KIGjT1bZ1$uGpk3HwXHDTsOBT1Q/BpBbCe5Dxu4eKyqIx1RlWbkN1";
  };

  networking.hostName = "steamdeck";

  programs.steam = {
    enable = true;
    localNetworkGameTransfers.openFirewall = true;
    remotePlay.openFirewall = true;
  };

  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      user = "marie";
      desktopSession = "plasma";
      updater.splash = "jovian";
    };
    decky-loader.enable = true;
    devices.steamdeck = {
      enable = true;
      autoUpdate = true;
      enableFwupdBiosUpdates = false;
      enableGyroDsuService = true;
    };
  };

  services = {
    displayManager.plasma-login-manager.enable = lib.mkForce false;
    flatpak.enable = true;
  };

  nixpkgs.config.allowUnfree = true;
  security.sudo-rs.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    kdePackages.plasma-keyboard
    qt6.qtvirtualkeyboard
    drawy

    heroic
    switchfin
    moonlight-qt
  ];

  powerManagement.cpuFreqGovernor = "schedutil";

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      luks.devices.root = {
        allowDiscards = true;
        device = "/dev/disk/by-uuid/a4be6a85-2e54-4c54-a330-669b86bf430e";
      };
      unl0kr = {
        enable = true;
        allowVendorDrivers = true;
        settings = {
          general = {
            backend = "drm";
            animations = true;
          };
          theme = {
            default = "pmos-dark";
            alternate = "pmos-light";
          };
          keyboard.layout = "de";
        };
      };
      # Fix amdgpu not found
      systemd.services.unl0kr-agent.after = [ "systemd-modules-load.service" ];
    };
    plymouth.enable = lib.mkForce false;
    kernelParams = [
      "rd.systemd.show_status=auto"
    ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = [
        "compress=zstd"
        "subvol=@"
      ];
    };
    "/home" = {
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = [
        "compress=zstd"
        "subvol=@home"
      ];
    };
    "/nix" = {
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = [
        "compress=zstd"
        "subvol=@nix"
        "noatime"
      ];
    };
    "/boot" = {
      device = "/dev/disk/by-label/esp";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "umask=0077"
      ];
    };
  };
}
