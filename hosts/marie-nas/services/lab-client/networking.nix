{ ... }:
{
  systemd.network = {
    enable = true;
    networks = {
      ethernet = {
        matchConfig = {
          Type = "ether";
          Virtualization = "container";
        };
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
          MulticastDNS = true;
          LinkLocalAddressing = true;
        };
      };
    };
  };
}
