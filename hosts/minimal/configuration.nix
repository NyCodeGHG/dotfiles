{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./disks.nix
  ];

  networking.hostName = "minimal";
  uwumarie.profiles.users.marie = true;
  system.stateVersion = "23.11";
}
