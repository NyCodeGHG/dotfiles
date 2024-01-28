{ pkgs, config, lib, ... }:
let
  iface = "dn42n0";
  port = 51821;
in
{
  networking.firewall.allowedUDPPorts = [ port ];
  age.secrets.dn42-peer-emma-wg-private = {
    file = ../../../../secrets/dn42/emma-wg-private.age;
    owner = "systemd-network";
    group = "systemd-network";
  };
  systemd.network = {
    enable = true;
    networks."70-dn42-emma" = {
      name = iface;
      DHCP = "no";
      networkConfig = {
        IPv6AcceptRA = false;
        IPForward = "yes";
        KeepConfiguration = "yes";
      };
      addresses = [
        {
          addressConfig = {
            Address = "fdf1:3ba4:9723::1/128";
            Peer = "fd42:e99e:1f58::1/128";
          };
        }
      ];
    };
    netdevs."70-dn42-emma" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = iface;
      };
      wireguardConfig = {
        PrivateKeyFile = config.age.secrets.dn42-peer-emma-wg-private.path;
        ListenPort = port;
      };
      wireguardPeers = [
        {
          wireguardPeerConfig = {
            PublicKey = "6IgFC2JAZ0xjZhDaH3YxpruFtMkoEPralJXzctBCnyA=";
            Endpoint = "2a03:4000:47:251:::51821";
            AllowedIPs = [ "fe80::/64" "fd00::/8" ];
          };
        }
      ];
    };
  };
}
