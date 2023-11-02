{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/profiles/all-hardware.nix"
  ];
  nixpkgs.hostPlatform = "x86_64-linux";
}
