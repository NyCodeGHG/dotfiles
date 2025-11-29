{ ... }:
{
  networking = {
    hostName = "delphi";
    nftables.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
      ];
      allowedUDPPorts = [
        443
      ];
    };
    useNetworkd = true;
    useDHCP = false;
  };
  systemd.network = {
    enable = true;
    networks = {
      "10-ethernet" = {
        matchConfig = {
          Type = [ "ether" ];
          Kind = [ "!veth" ];
        };
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
          KeepConfiguration = "yes";
        };
        dhcpV4Config.UseDNS = false;
        dhcpV6Config.UseDNS = false;
        ipv6AcceptRAConfig.UseDNS = false;
      };
    };
    config.networkConfig.IPv6PrivacyExtensions = false;
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };
}
