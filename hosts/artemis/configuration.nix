{ inputs, ... }:
{
  imports = with inputs; [
    home-manager.nixosModules.default
    agenix.nixosModules.default
    ../../config/nixos/system/acme.nix
    ./monitoring
    ./applications
    ./hardware.nix
    ./postgres.nix
    # ./restic.nix
    ./networking.nix
    ./dn42
  ];
  uwumarie.profiles = {
    fail2ban = true;
    openssh = true;
    acme = true;
    nginx = true;
    nix = true;
    users.marie = true;
  };

  services.qemuGuest.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  security.sudo.wheelNeedsPassword = false;

  console.keyMap = "de";

  system.stateVersion = "22.11";

  programs.mtr.enable = true;

  # age.rekey = {
  #   hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAFQjqgMtqrMy7AKCQN4aMZitASg9MWEP1u6lfVdA0v8";
  #   masterIdentities = [ "/home/marie/.ssh/default.ed25519" ];
  # };
}
