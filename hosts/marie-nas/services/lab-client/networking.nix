{ ... }:
{
  uwumarie.profiles.dns = false;
  services.resolved.enable = true;

  systemd.network = {
    enable = true;
    networks = {
      eth0 = {
        matchConfig = {
          Name = "eth0";
          Virtualization = "container";
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
          Name = "lab-lan";
          Virtualization = "container";
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
      };
    };
  };
}
