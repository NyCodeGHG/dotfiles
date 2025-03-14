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
    nginx.enable = true;
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

  users.users.builder = {
    isSystemUser = true;
    openssh.authorizedKeys.keys = [
      # Marie desktop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFiS+tzh0R/nN5nqSwvLerCV4nBwI51zOKahFfiiINGp"
      # root@marie-desktop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKl1gOAizi410fKbP0wP6+XJMAk+JDx+mLp2amPKKQPY"
    ];
    group = "builder";
    shell = pkgs.bashInteractive;
  };
  users.groups.builder = { };

  nix.settings.trusted-users = [ "builder" ];
}
