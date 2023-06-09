{ config, pkgs, lib, ... }:
let
  mkGroups = with lib; groups: flatten (concatMap (value: optional (head value) (tail value)) groups);
in
{
  users.users.marie = {
    isNormalUser = true;
    extraGroups = mkGroups [
      [ config.networking.networkmanager.enable "networkmanager" ]
      [ (config.security.sudo.enable || config.security.doas.enable) "wheel" ]
      [ config.virtualisation.podman.enable "podman" ]
      [ config.virtualisation.docker.enable "docker" ]
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      # Desktop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFiS+tzh0R/nN5nqSwvLerCV4nBwI51zOKahFfiiINGp"
      # Laptop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIESHraJJ0INX/OAXOQUR4UuLEre/2N70Uh3H5YkFC5zz"
    ];
  };
  programs.zsh.enable = true;
}
