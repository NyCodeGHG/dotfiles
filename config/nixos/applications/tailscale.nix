{ config, lib, ... }:
{
  systemd.network.wait-online.ignoredInterfaces = lib.mkIf config.services.tailscale.enable [
    "tailscale0"
  ];
}
