{ pkgs, inputs, ... }:
{
  imports = with inputs; [
    agenix.nixosModules.default
    ../../config/nixos/system/acme.nix
    ../../config/nixos/applications/tailscale.nix
    ../../config/nixos/monitoring
    ./monitoring
    ./applications
    ./hardware.nix
    ./postgres.nix
    ./restic.nix
    ./networking.nix
    ./dn42
  ];
  uwumarie.profiles = {
    fail2ban = true;
    acme = true;
    nginx.enable = true;
    nix = true;
    users.marie = true;
    headless = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_6_18;
  services.qemuGuest.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  security.sudo.wheelNeedsPassword = false;
  security.sudo-rs.wheelNeedsPassword = false;

  console.keyMap = "de";

  system.stateVersion = "22.11";

  programs.mtr.enable = true;

  environment.systemPackages = with pkgs; [
    yt-dlp
    rclone
    magic-wormhole
  ];

  uwumarie.agenix.enable = true;
}
