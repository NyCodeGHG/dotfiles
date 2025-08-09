{ config, lib, ... }:
lib.mkIf config.services.tailscale.enable {
  systemd.network.wait-online.ignoredInterfaces = [ "tailscale0" ];
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  systemd.services.tailscaled = lib.mkMerge [
    (lib.mkIf config.networking.nftables.enable {
      after = [ "nftables.service" ];
      environment.TS_DEBUG_FIREWALL_MODE = "nftables";
    })
    { restartIfChanged = false; }
  ];
}
