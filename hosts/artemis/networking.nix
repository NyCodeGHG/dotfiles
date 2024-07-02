{ config, pkgs, ... }:
let
  port = 51820;
in
{
  environment.systemPackages = with pkgs; [ wireguard-tools ];

  services.resolved.enable = false;

  networking = {
    hostName = "artemis";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 1234 ];
      logRefusedConnections = false;
      pingLimit = "2/minute burst 5 packets";

      interfaces.wg0.allowedTCPPorts = [ 53 ];
      interfaces.wg0.allowedUDPPorts = [ 53 ];
      interfaces.dn42.allowedUDPPorts = [ 53 ];
      interfaces.dn42.allowedTCPPorts = [ 53 ];

      # bgp, dns from dn42
      interfaces."dn42n*".allowedTCPPorts = [ 179 53 ];
      interfaces."dn42n*".allowedUDPPorts = [ 53 ];

      trustedInterfaces = [ "dn42" ];
      allowedUDPPorts = [ port (port + 200) ];
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
        content = builtins.readFile ./firewall.nft;
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
        networkConfig = {
          KeepConfiguration = "yes";
          IPv6AcceptRA = false;
          IPv6ProxyNDP = true;
          IPv6ProxyNDPAddress = [
            "2a03:4000:5f:f5b:8596:a039:73f9:f2bf"
          ];
        };
      };
      "50-wg0" = {
        name = "wg0";
        address = [
          "10.69.0.1/24"
          "10.42.0.18/32"
          "fdf1:3ba4:9723:1000::1/64"
        ];
      };
      "50-wg1" = {
        name = "wg1";
        address = [
          "2a03:4000:5f:f5b::/128"
        ];
      };
    };
    netdevs = {
      "50-wg0" = {
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
          {
            # raspberrypi
            wireguardPeerConfig = {
              PublicKey = "dsK1pAePkg4YvuMYBDDVqOyMIKudscMcH3nn1Dag7jQ=";
              AllowedIPs = [ "10.69.0.3/32" "192.168.1.0/24" ];
              PersistentKeepalive = 25;
            };
          }
          {
            # marie pixel smartphone
            wireguardPeerConfig = {
              PublicKey = "evf0qYXAybDRj1xRnWzWFBoofc6LSBZd9NpOLoi7PwE=";
              AllowedIPs = [ "10.69.0.9/32" "fdf1:3ba4:9723:1000::4/128" ];
              PersistentKeepalive = 25;
            };
          }
          {
            # marie desktop win11
            wireguardPeerConfig = {
              PublicKey = "Ramif2e77i0Z7t9TjdvA4vO/tMOBj8k2li4an3HXTRY=";
              AllowedIPs = [ "10.69.0.5/32" "fdf1:3ba4:9723:1000::2/128" ];
              PersistentKeepalive = 25;
            };
          }
          {
            # firetv stick
            wireguardPeerConfig = {
              PublicKey = "ix5kGyVlSASM0EruH3kzZtMwd0QJ0Ar8v6IIs24Jzzo=";
              AllowedIPs = [ "10.69.0.6/32" ];
              PersistentKeepalive = 25;
            };
          }
          {
            # delphi
            wireguardPeerConfig = {
              PublicKey = "qj6y6xfFtYga5hpT8FygOAOKN0xIDO5+sdtT8K2ozUc=";
              AllowedIPs = [ "10.69.0.7/32" "fdf1:3ba4:9723:2000::1/128" ];
              Endpoint = "141.144.240.28:51820";
            };
          }
          {
            # tobi nas
            wireguardPeerConfig = {
              PublicKey = "aFMhUNLlj6oF3iDqUdlcJR1sxVjjRSDJ1S8bcH+fwhA=";
              AllowedIPs = [ "10.69.0.8/32" "192.168.178.0/24" ];
              PersistentKeepalive = 25;
            };
          }
          {
            # bjarne
            wireguardPeerConfig = {
              PublicKey = "TfOvrs1e3J/PM2H9BNdY9WlhG5ajVRGXTFgiU+cuD20=";
              AllowedIPs = [ "10.69.0.10/32" ];
            };
          }
          {
            # bjarne homeserver backup
            wireguardPeerConfig = {
              PublicKey = "JauuZ0kyM7GZF7lTSev5T0VkOeEBDPGwJIi7JYlX7Hg=";
              AllowedIPs = [ "10.69.0.11/32" ];
              Endpoint = "2a02:8071:d80:2100:921b:eff:fe04:3a4a:51822";
            };
          }
          {
            # bjarne homeserver
            wireguardPeerConfig = {
              PublicKey = "UXJWqDuCRIqbmnxh29NzL6+ymQ/Lo/71EUbrDRdqsmk=";
              AllowedIPs = [ "10.42.0.0/24" ];
              Endpoint = "2a02:8071:d80:2100:921b:eff:fe04:3a4a:51820";
            };
          }
        ];
      };
      "50-wg1" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg1";
        };
        wireguardConfig = {
          PrivateKeyFile = config.age.secrets.wg1-private.path;
          ListenPort = port + 200;
          RouteTable = "main";
        };
        wireguardPeers = [
          {
            # gitlabber
            wireguardPeerConfig = {
              PublicKey = "VjZxw3D2YJIAvGF5APDOVeKzYNnEfSUzcBVPLqc7i2E=";
              AllowedIPs = [ "2a03:4000:5f:f5b:8596:a039:73f9:f2bf/128" ];
              PersistentKeepalive = 25;
            };
          }
        ];
      };
    };
  };

  age.secrets.wg-private = {
    file = ../../secrets/artemis-wg-privatekey.age;
    owner = "systemd-network";
    group = "systemd-network";
  };

  age.secrets.wg1-private = {
    file = ./secrets/wg1-private.age;
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
