{ ... }:
{
  systemd.network = {
    enable = true;
    config.networkConfig.IPv6Forwarding = true;
    networks = {
      "20-router" = {
        matchConfig.Name = "enp14s0";
        networkConfig = {
          DHCPServer = true;
          Address = "10.10.10.1/24";
          IPMasquerade = "ipv4";
          IPv6AcceptRA = false;
          IPv6SendRA = true;
          DHCPPrefixDelegation = true;
        };
        dhcpServerConfig = {
          ServerAddress = "10.10.10.1/24";
          PoolSize = 100;
          DefaultLeaseTimeSec = "12h";
          EmitDNS = true;
          PersistLeases = true;
        };
        dhcpPrefixDelegationConfig = {
          UplinkInterface = "wlan0";
          Announce = true;
        };
      };
      "30-wifi" = {
        matchConfig.Name = "wlan0";
        networkConfig = {
          DHCP = true;
          DHCPPrefixDelegation = true;
          IPv6AcceptRA = true;
        };
        dhcpV6Config.PrefixDelegationHint = "::/62";
        dhcpPrefixDelegationConfig = {
          UplinkInterface = ":self";
          SubnetId = "0x0";
          Announce = false;
        };
      };
    };
  };
  networking = {
    networkmanager.unmanaged = [ "enp14s0" ];
    firewall.allowedUDPPorts = [
      # allow dhcp
      67
    ];
  };
}
