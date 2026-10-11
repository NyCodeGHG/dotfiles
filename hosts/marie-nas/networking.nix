{ lib, ... }:
{
  networking = {
    hostName = "marie-nas";
    useDHCP = false;
    nftables.enable = true;
    firewall = {
      allowedTCPPorts = [
        80
        443
      ];
      allowedUDPPorts = [
        443
        5353 # sd-resolved
      ];
      extraForwardRules = ''
        iifname "br0" oifname "br0" accept
      '';
    };
  };
  systemd.network = {
    enable = true;
    networks = {
      ethernet = {
        matchConfig = {
          Type = [ "ether" ];
          Kind = "!*";
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
          DHCP = true;
          IPv6AcceptRA = true;
          MulticastDNS = true;
        };
        dhcpV4Config = {
          UseDNS = true;
          UseNTP = true;
          UseDomains = true;
        };
        dhcpV6Config = {
          UseDNS = true;
          UseNTP = true;
          UseDomains = true;
        };
        ipv6AcceptRAConfig = {
          UseDNS = true;
          UseDomains = true;
        };
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
    settings.Resolve.MulticastDNS = true;
  };
}
