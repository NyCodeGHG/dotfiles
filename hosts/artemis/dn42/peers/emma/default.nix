{ pkgs, config, lib, ... }:
let
  iface = "dn42n0";
  port = 51821;
in
{
  networking.firewall.allowedUDPPorts = [ port ];
  age.secrets.dn42-peer-emma-wg-private = {
    file = ./wg-private.age;
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
            Address = "fe80::d56f:a7fc:c62d:b88a/64";
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
