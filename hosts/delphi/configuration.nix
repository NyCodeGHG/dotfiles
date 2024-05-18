{ modulesPath, ... }:
{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    "${modulesPath}/profiles/headless.nix"
    ./networking.nix
    ./monitoring
    ./applications
    ./minecraft.nix
    ./hardware.nix
  ];
  uwumarie.profiles = {
    openssh = true;
    acme = true;
    nginx = true;
    nix = true;
    users.marie = true;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  security.sudo.wheelNeedsPassword = false;
  time.timeZone = "Europe/Berlin";

  system.stateVersion = "23.11";

  #  age.rekey = {
  #    hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAEuAOf1ZSr7L/IoaYmCC9R+QaXfKoC2F03N/Z0dfUT3";
  #    masterIdentities = [ "/home/marie/.ssh/default.ed25519" ];
  #  };
}
