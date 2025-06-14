{ ... }:
{
  networking = {
    hostName = "marie-nas";
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
          IPv6AcceptRA = true;
          KeepConfiguration = "yes";
        };
        dhcpV4Config.UseDNS = false;
        dhcpV6Config.UseDNS = false;
        ipv6AcceptRAConfig.UseDNS = false;
      };
    };
    links = {
      "50-wake-on-lan" = {
        matchConfig = {
          MACAddress = "2c:fd:a1:ba:fc:34";
        };
        linkConfig = {
          MACAddressPolicy = "persistent";
          WakeOnLan = "magic";
        };
      };
    };
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  services.resolved = {
    enable = true;
    extraConfig = ''
      MulticastDNS=false
    '';
  };
}
