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
  services = {
    avahi = {
      enable = true;
      openFirewall = true;
      nssmdns4 = true;
      nssmdns6 = true;
      publish = {
        enable = true;
        userServices = true;
      };
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
}
