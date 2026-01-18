{ pkgs, ... }:
{
  networking = {
    hostName = "marie-desktop";
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
    useDHCP = false;
    firewall.logRefusedConnections = false;
  };
  systemd.network.wait-online.enable = false;
  services = {
    avahi = {
      enable = true;
      openFirewall = true;
      nssmdns4 = true;
    };
    printing = {
      enable = true;
      drivers = with pkgs; [ hplip ];
    };
    resolved = {
      enable = true;
      settings.Resolve.MulticastDNS = "resolve";
    };
    tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };
  };

  systemd.network = {
    enable = true;
    networks = {
      lan = {
        matchConfig = {
          MACAddress = [
            "d8:43:ae:a2:ae:2d"
            "58:cd:c9:86:55:9b"
          ];
        };
        routingPolicyRules = [
          {
            To = "192.168.1.0/24";
            Priority = 2500;
          }
        ];
        networkConfig = {
          MulticastDNS = "resolve";
        };
      };
    };
  };
}
