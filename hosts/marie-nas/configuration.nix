{ pkgs, ... }:
{
  imports = [
    ./networking.nix
    ./state.nix
    ./zfs.nix
    ./hardware.nix
    ./powersave.nix
  ];
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        memtest86.enable = true;
      };
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_6_12;
  };

  uwumarie.profiles = {
    headless = true;
  };

  environment.systemPackages = with pkgs; [
    fio
  ];

  system.stateVersion = "24.11";
}
