{ config, pkgs, ... }:
let
  port = 51820;
in
{
  environment.systemPackages = with pkgs; [ wireguard-tools ];

  networking = {
    hostName = "artemis";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 ];
      logRefusedConnections = false;
      pingLimit = "2/minute burst 5 packets";
      # Allow Loki access from Wireguard
      interfaces.wg0.allowedTCPPorts = [
        3030
      ];
      allowedUDPPorts = [ port ];
    };
    nftables.enable = true;
    useDHCP = false;
    nameservers = [
      # Netcup
      "2a03:4000:0:1::e1e6"
      "2a03:4000:8000::fce6"
      "46.38.225.230"
      "46.38.252.230"
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
      };
      "50-wg0" = {
        name = "wg0";
        address = ["10.69.0.1/24"];
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
            AllowedIPs = [ "10.69.0.4/32" ];
            PersistentKeepalive = 25;
          };
        }
        { # marie desktop win11
          wireguardPeerConfig = {
            PublicKey = "AxWlpfetKOpXU8LdlNvAdE/CO4259fmXJYC7YTbtgzw=";
            AllowedIPs = [ "10.69.0.5/32" ];
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
