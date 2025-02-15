{ pkgs, ... }:
{
  imports = [
    ./networking.nix
    ./state.nix
    ./zfs.nix
    ./hardware.nix
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

  environment.systemPackages = with pkgs; [
    fio
  ];
}
