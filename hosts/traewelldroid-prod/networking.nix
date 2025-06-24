{ ... }:
{
  networking = {
    hostName = "traewelldroid-prod";
    useDHCP = false;
    nftables.enable = true;
    firewall.allowedTCPPorts = [
      80
      443
    ];
  };
  systemd.network = {
    enable = true;
    networks = {
      ethernet = {
        matchConfig = {
          Type = [ "ether" ];
          Kind = [ "!veth" ];
        };
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = false;
        };
        dhcpV4Config.UseDNS = false;
        dhcpV6Config.UseDNS = false;
        ipv6AcceptRAConfig.UseDNS = false;

        address = [ "2a01:4f8:c2c:1997::1/64" ];
        gateway = [ "fe80::1" ];
      };
    };
  };

  services.resolved = {
    enable = true;
    extraConfig = ''
      MulticastDNS=false
    '';
  };
}
