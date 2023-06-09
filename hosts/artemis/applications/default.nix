{ config, pkgs, lib, ... }:
{
  imports = [
    ./authentik.nix
    ./coder.nix
    ./gitlab.nix
    ./jellyfin.nix
    ./miniflux.nix
    ./matrix.nix
  ];
}
