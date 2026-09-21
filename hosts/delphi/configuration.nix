{
  modulesPath,
  inputs,
  pkgs,
  ...
}:
{
  imports = with inputs; [
    agenix.nixosModules.default
    ../../config/nixos/system/acme.nix
    ../../config/nixos/applications/tailscale.nix
    ../../config/nixos/monitoring
    "${modulesPath}/profiles/qemu-guest.nix"
    "${modulesPath}/profiles/headless.nix"
    ./networking.nix
    ./applications
    ./hardware.nix
  ];
  uwumarie.profiles = {
    acme = true;
    nginx.enable = true;
    nix = true;
    users.marie = true;
    headless = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_6_18;
  environment.systemPackages = with pkgs; [ p7zip ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  security.sudo.wheelNeedsPassword = false;
  security.sudo-rs.wheelNeedsPassword = false;
  time.timeZone = "Europe/Berlin";

  system.stateVersion = "23.11";
}
