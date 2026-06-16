{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    openFirewall = true;
  };

  systemd = {
    network.wait-online.ignoredInterfaces = [ "tailscale0" ];
    services.tailscaled.environment.TS_DEBUG_FIREWALL_MODE = "nftables";
  };

  environment.etc."alloy/tailscale.alloy".text = ''
    scrape "tailscale" {
      name = "tailscale"
      targets = [
        {"__address__" = "100.100.100.100", "instance" = constants.hostname},
      ]
    }
  '';
}