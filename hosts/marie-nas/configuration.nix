{ pkgs, ... }:
{
  imports = [
    ./disko.nix
    ./networking.nix
    ./state.nix
    ./zfs.nix
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
}
