{ ... }:
{
  networking.useDHCP = false;
  uwumarie.profiles.dns = false;
  services.resolved.enable = true;

  networking.hostName = "lab-client";

  services.clatd.enable = true;

  systemd.network = {
    enable = true;
    networks = {
      regular-lan = {
        matchConfig = {
          MACAddress = "10:66:6a:05:f4:ac";
        };
        linkConfig = {
          RequiredForOnline = false;
        };
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
          MulticastDNS = true;
          LinkLocalAddressing = "ipv6";
        };
        dhcpV4Config = {
          UseRoutes = false;
          UseDNS = false;
        };
        ipv6AcceptRAConfig = {
          UseGateway = false;
          UseRoutePrefix = false;
          UseDNS = false;
          DHCPv6Client = false;
        };
      };
      lab-lan = {
        matchConfig = {
          MACAddress = "10:66:6a:5a:3a:46";
        };
        linkConfig = {
          RequiredForOnline = "routable";
        };
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
          MulticastDNS = true;
          LinkLocalAddressing = "ipv6";
        };
        dhcpV4Config = {
          IPv6OnlyMode = true;
        };
        ipv6AcceptRAConfig = {
          UsePREF64 = true;
        };
      };
    };
  };
}
