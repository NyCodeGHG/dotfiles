{
  imports = [
    ./monitoring
    ./applications
    ./hardware.nix
    ./postgres.nix
    ./wireguard.nix
    ./restic.nix
    ./networking.nix
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
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "22.11";
}
