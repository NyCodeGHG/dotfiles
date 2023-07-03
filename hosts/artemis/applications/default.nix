{ config, pkgs, lib, ... }:
{
  imports = [
    ./authentik.nix
    ./coder.nix
    ./gitlab
    ./jellyfin.nix
    ./miniflux.nix
    ./matrix
    ./ip-playground.nix
  ];
}
