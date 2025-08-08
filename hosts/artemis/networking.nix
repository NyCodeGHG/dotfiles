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
      allowedTCPPorts = [
        80
        443
        1234
      ];
      logRefusedConnections = false;
      pingLimit = "2/minute burst 5 packets";

      interfaces.wg0.allowedTCPPorts = [ 53 ];
      interfaces.wg0.allowedUDPPorts = [ 53 ];
      interfaces.dn42.allowedUDPPorts = [ 53 ];
      interfaces.dn42.allowedTCPPorts = [ 53 ];

      # bgp, dns from dn42
      interfaces."dn42n*".allowedTCPPorts = [
        179
        53
      ];
      interfaces."dn42n*".allowedUDPPorts = [ 53 ];

      trustedInterfaces = [ "dn42" ];
      allowedUDPPorts = [
        port
        (port + 200)
      ];
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
          { Gateway = "89.58.8.1"; }
          { Gateway = "fe80::1"; }
        ];
        networkConfig = {
          KeepConfiguration = "yes";
          IPv6AcceptRA = false;
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
            # tobi nas
            PublicKey = "aFMhUNLlj6oF3iDqUdlcJR1sxVjjRSDJ1S8bcH+fwhA=";
            AllowedIPs = [
              "10.69.0.8/32"
              "192.168.178.0/24"
            ];
            PersistentKeepalive = 25;
          }
        ];
      };
    };
    config.networkConfig.IPv6PrivacyExtensions = false;
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

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };
  systemd.services.tailscaled = {
    after = [ "nftables.service" ];
    environment.TS_DEBUG_FIREWALL_MODE = "nftables";
  };
}
