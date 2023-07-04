{ pkgs, config, lib, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    "${modulesPath}/profiles/headless.nix"
    ../../modules/motd.nix
    ../../modules/nix-config.nix
    ../../profiles/acme.nix
    ../../profiles/reverse-proxy.nix
    ./wireguard.nix
    # ./minecraft.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  security.sudo.wheelNeedsPassword = false;

  networking = {
    hostName = "delphi";
    # Use OCI firewall
    firewall.enable = false;
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };

  time.timeZone = "Europe/Berlin";

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
    };
  };
  system.stateVersion = "23.11";
  uwumarie.services.motd.enable = true;

  disko.devices = import ./disk-config.nix {
    inherit lib;
  };
}
