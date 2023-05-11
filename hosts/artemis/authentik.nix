{ config, pkgs, lib, ... }:
{
  imports = [
    ../../modules/authentik.nix
  ];

  virtualisation.podman.enable = true;
  uwumarie.services.authentik = {
    enable = true;
  };
}
