{ lib, ... }:
{
  networking = {
    hostName = "marie-nas";
    useDHCP = false;
    nftables.enable = true;
    firewall.allowedTCPPorts = [
      80
      443
    ];
    firewall.allowedUDPPorts = [
      443
    ];
  };
  systemd.network = {
    enable = true;
    networks = {
      ethernet = {
        matchConfig = {
          Type = [ "ether" ];
          Kind = [ "!veth bridge tap tun" ];
        };
        networkConfig = {
          Bridge = "br0";
        };
      };
      "25-br0" = {
        matchConfig = {
          Name = "br0";
        };
        linkConfig = {
          RequiredForOnline = "routable";
        };
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
          MulticastDNS = "resolve";
        };
        dhcpV4Config.UseDNS = false;
        dhcpV6Config.UseDNS = false;
        ipv6AcceptRAConfig.UseDNS = false;
      };
      "25-br1" = {
        matchConfig = {
          Name = "br1";
        };
        linkConfig = {
          RequiredForOnline = false;
        };
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
          MulticastDNS = "resolve";
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
      "25-br0" = {
        matchConfig = {
          OriginalName = "br0";
        };
        linkConfig = {
          MACAddressPolicy = "persistent";
        };
      };
    };
    netdevs = {
      "25-br0" = {
        netdevConfig = {
          Name = "br0";
          Kind = "bridge";
          MACAddress = "none";
        };
      };
      "25-br1" = {
        netdevConfig = {
          Name = "br1";
          Kind = "bridge";
        };
      };
    };
    config = {
      networkConfig = {
        SpeedMeter = true;
        IPv6PrivacyExtensions = false;
      };
    };
  };

  services.resolved = {
    enable = true;
    settings.Resolve.MulticastDNS = "resolve";
  };
  networking.firewall.trustedInterfaces = [ "podman*" "talos" ];
}
