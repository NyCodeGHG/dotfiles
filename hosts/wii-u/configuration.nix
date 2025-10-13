{ pkgs, ... }:
{
  wii-u.enable = true;

  fileSystems = {
    "/" = {
      device = "/dev/mmcblk0p2";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/mmcblk0p1";
      fsType = "vfat";
    };
  };

  uwumarie.profiles = {
    base = false;
    headless = true;
    ntp = false;
    zram = false;
  };

  environment.systemPackages = with pkgs; [
    fastfetchMinimal
    libinput
    iperf
    btop
    westonLite
  ];

  nix.package = pkgs.lix.overrideAttrs (prev: {
    patches = prev.patches ++ [
      ../../patches/lix-powerpc-system.patch
    ];
  });

  networking = {
    hostName = "wiiu";
    useDHCP = false;
  };

  systemd.network = {
    enable = true;
    networks = {
      "ethernet" = {
        matchConfig = {
          Type = [ "ether" ];
          Kind = [ "!veth" ];
        };
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
        };
      };
    };
    config.networkConfig.IPv6PrivacyExtensions = false;
  };

  boot.initrd.systemd.enable = true;
  programs.command-not-found.enable = false;
  documentation.nixos.enable = false;

  system.tools = {
    nixos-build-vms.enable = false;
    nixos-enter.enable = false;
    nixos-generate-config.enable = false;
    nixos-install.enable = false;
    nixos-option.enable = false;
  };

  security.sudo.wheelNeedsPassword = false;

  hardware.graphics.enable = true;
}
