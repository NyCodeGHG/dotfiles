{ modulesPath, inputs, pkgs, ... }:
{
  imports = with inputs; [
    agenix.nixosModules.default
    ../../config/nixos/system/acme.nix
    "${modulesPath}/profiles/qemu-guest.nix"
    "${modulesPath}/profiles/headless.nix"
    ./networking.nix
    ./monitoring.nix
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
    headless = true;
  };

  environment.systemPackages = with pkgs; [ p7zip ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  security.sudo.wheelNeedsPassword = false;
  security.sudo-rs.wheelNeedsPassword = false;
  time.timeZone = "Europe/Berlin";

  system.stateVersion = "23.11";

  #  age.rekey = {
  #    hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAEuAOf1ZSr7L/IoaYmCC9R+QaXfKoC2F03N/Z0dfUT3";
  #    masterIdentities = [ "/home/marie/.ssh/default.ed25519" ];
  #  };
}
