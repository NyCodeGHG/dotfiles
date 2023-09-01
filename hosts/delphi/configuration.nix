{ pkgs, config, lib, modulesPath, self, ... }:
{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    "${modulesPath}/profiles/headless.nix"
    ../../profiles/nix-config.nix
    ../../profiles/acme.nix
    ../../profiles/nginx.nix
    ../../profiles/fail2ban.nix
    ../../profiles/locale.nix
    ../../profiles/openssh.nix
    ./wireguard.nix
    ./networking.nix
    ./monitoring
    ./applications
    ./minecraft.nix
  ] ++ (with self.inputs; [
    agenix.nixosModules.default
    disko.nixosModules.default
  ]);

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  security.sudo.wheelNeedsPassword = false;
  time.timeZone = "Europe/Berlin";

  system.stateVersion = "23.11";

  disko.devices = import ./disk-config.nix {
    inherit lib;
  };
}
