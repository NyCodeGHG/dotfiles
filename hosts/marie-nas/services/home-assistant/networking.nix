{ ... }:
{
  systemd.network = {
    enable = true;
    networks = {
      ethernet = {
        matchConfig = {
          Name = "eth0";
          Virtualization = "container";
        };
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
          MulticastDNS = "resolve";
          LinkLocalAddressing = true;
        };
        dhcpV4Config.UseDNS = false;
        dhcpV6Config.UseDNS = false;
        ipv6AcceptRAConfig.UseDNS = false;
      };
    };
    config.networkConfig = {
      IPv6PrivacyExtensions = false;
    };
  };
}
