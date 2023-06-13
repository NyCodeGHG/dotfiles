{ pkgs, config, lib, modulesPath }:
{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    "${modulesPath}/profiles/headless.nix"
    ../../modules/motd.nix
    ../../modules/nix-config.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  security.sudo.wheelNeedsPassword = false;

  networking = {
    hostName = "delphi";
    # Use OCI firewall
    firewall.enable = false;
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
