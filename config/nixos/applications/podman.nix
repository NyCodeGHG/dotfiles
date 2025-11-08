{ config, lib, ... }:
{
  networking.firewall.trustedInterfaces = lib.mkIf config.virtualisation.podman.enable [ "podman*" ];
}
