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
