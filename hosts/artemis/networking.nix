{ config, pkgs, ... }:
let
  port = 51820;
in
{
  environment.systemPackages = with pkgs; [ wireguard-tools ];

  services.resolved.enable = false;
  services.dnsmasq = {
    enable = true;
    settings = {
      server = [
        "/dn42/fd42:d42:d42:54::1"
        "/dn42/fd42:d42:d42:53::1"
        "/d.f.ip6.arpa/fd42:d42:d42:54::1"
        "/d.f.ip6.arpa/fd42:d42:d42:53::1"
      ];
    };
  };

  networking = {
    hostName = "artemis";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 1234 ];
      logRefusedConnections = false;
      pingLimit = "2/minute burst 5 packets";
      # Allow Loki access from Wireguard
      interfaces.wg0.allowedTCPPorts = [ 3030 53 ];
      interfaces.wg0.allowedUDPPorts = [ 53 ];
      # bgp from dn42
      interfaces."dn42n*".allowedTCPPorts = [ 179 ];
      trustedInterfaces = [ "dn42" ];
      allowedUDPPorts = [ port ];
      checkReversePath = "loose";
      extraInputRules = ''
        # make traceroute work
        udp dport { 33434-33523 } reject
      '';
    };
    nftables = {
      enable = true;
      tables.forwarding = {
        family = "inet";
        content = ''
          chain prerouting {
            type filter hook prerouting priority -100;
            ip6 daddr fd42:e99e:1f58::/48 meta nftrace set 1
          }
          chain forward {
            type filter hook forward priority 0; policy drop;

            iifname "dn42n*" oifname "dn42n*" accept
            iifname wg0 accept
            ct state { established, related } accept
            icmpv6 type != { nd-redirect, 139 } accept
            meta nftrace set 1
          }
        '';
      };
    };
    useDHCP = false;
    nameservers = [
      # Cloudflare
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
      "1.1.1.1"
      "1.0.0.1"
      # Google
      "2001:4860:4860::8888"
      "2001:4860:4860::8844"
      "8.8.8.8"
      "8.8.4.4"
    ];
  };

  systemd.network = {
    enable = true;
    networks = {
      "10-ens3" = {
        name = "ens3";
        DHCP = "no";
        address = [
          "89.58.10.36/22"
          "2a03:4000:5f:f5b::/64"
        ];
        routes = [
          { routeConfig.Gateway = "89.58.8.1"; }
          { routeConfig.Gateway = "fe80::1"; }
        ];
        networkConfig.KeepConfiguration = "yes";
      };
      "50-wg0" = {
        name = "wg0";
        address = [
          "10.69.0.1/24"
          "fdf1:3ba4:9723:1000::1/64"
        ];
        networkConfig.KeepConfiguration = "yes";
      };
    };
    netdevs."50-wg0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
      };
      wireguardConfig = {
        PrivateKeyFile = config.age.secrets.wg-private.path;
        ListenPort = port;
        RouteTable = "main";
      };
      wireguardPeers = [
        { # raspberrypi
          wireguardPeerConfig = {
            PublicKey = "8XzwNX81oK3gXbOLcgLmYyxqZCz4K9HEfDUCbWfuegg=";
            AllowedIPs = [ "10.69.0.3/32" ];
            PersistentKeepalive = 25;
          };
        }
        { # marie pixel smartphone
          wireguardPeerConfig = {
            PublicKey = "bbeNjsvKgB/5TCeQ8zZw2cOUuVIp0UYyeNYmfyxKLDM=";
            AllowedIPs = [ "10.69.0.4/32" "fdf1:3ba4:9723:1000::3/128"];
            PersistentKeepalive = 25;
          };
        }
        { # marie desktop win11
          wireguardPeerConfig = {
            PublicKey = "AxWlpfetKOpXU8LdlNvAdE/CO4259fmXJYC7YTbtgzw=";
            AllowedIPs = [ "10.69.0.5/32" "fdf1:3ba4:9723:1000::2/128" ];
            PersistentKeepalive = 25;
          };
        }
        { # firetv stick
          wireguardPeerConfig = {
            PublicKey = "ix5kGyVlSASM0EruH3kzZtMwd0QJ0Ar8v6IIs24Jzzo=";
            AllowedIPs = [ "10.69.0.6/32" ];
            PersistentKeepalive = 25;
          };
        }
        { # delphi
          wireguardPeerConfig = {
            PublicKey = "qj6y6xfFtYga5hpT8FygOAOKN0xIDO5+sdtT8K2ozUc=";
            AllowedIPs = [ "10.69.0.7/32" ];
            Endpoint = "141.144.240.28:51820";
          };
        }
        { # tobi nas
          wireguardPeerConfig = {
            PublicKey = "aFMhUNLlj6oF3iDqUdlcJR1sxVjjRSDJ1S8bcH+fwhA=";
            AllowedIPs = [ "10.69.0.8/32" "192.168.178.0/24" ];
            PersistentKeepalive = 25;
          };
        }
      ];
    };
  };

  age.secrets.wg-private = {
    file = ../../secrets/artemis-wg-privatekey.age;
    owner = "systemd-network";
    group = "systemd-network";
  };

  boot.kernel.sysctl = {
    "net.ipv6.conf.default.accept_ra" = 0;
    "net.ipv6.conf.default.autoconf" = 0;
    "net.ipv6.conf.all.accept_ra" = 0;
    "net.ipv6.conf.all.autoconf" = 0;
    "net.ipv6.conf.ens3.accept_ra" = 0;
    "net.ipv6.conf.ens3.autoconf" = 0;

    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv4.conf.default.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
    "net.ipv6.conf.default.forwarding" = true;
  };
}
