{ modulesPath, inputs, pkgs, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./hydra.nix
  ];

  uwumarie.profiles = {
    headless = true;
  };

  uwumarie.profiles = {
    locale = false;
    ntp = false;
    zram = false;
    users.marie = true;
    nix = false;
    nginx.enable = false;
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "tabmeier12+acme@gmail.com";

  security.sudo-rs.wheelNeedsPassword = false;

  systemd = {
    enableEmergencyMode = false;
  };

  system.stateVersion = "25.11";

  boot.loader.limine = {
    enable = true;
    biosSupport = true;
    efiSupport = false;
    biosDevice = "/dev/sda";
    partitionIndex = 1;
    maxGenerations = 5;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
    "sr_mod"
  ];

  fileSystems."/" = {
    device = "/dev/sda3";
    fsType = "bcachefs";
  };

  fileSystems."/boot" = {
    device = "/dev/sda2";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  networking = {
    hostName = "hydra2";
    useDHCP = false;
    nftables.enable = true;
    firewall.allowedTCPPorts = [
      80
      443
    ];
  };
  systemd.network = {
    enable = true;
    networks = {
      ethernet = {
        matchConfig = {
          Type = [ "ether" ];
          Kind = [ "!veth" ];
        };
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = false;
        };
        dhcpV4Config.UseDNS = false;
        dhcpV6Config.UseDNS = false;
        ipv6AcceptRAConfig.UseDNS = false;

        address = [ "2a01:4f8:c0c:7e48::1/64" ];
        gateway = [ "fe80::1" ];
      };
    };
  };

  services.resolved = {
    enable = true;
    extraConfig = ''
      MulticastDNS=false
    '';
  };
}
