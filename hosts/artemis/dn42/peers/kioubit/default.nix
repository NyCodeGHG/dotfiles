{ pkgs, config, lib, ... }:
let
  iface = "dn42n1";
  port = 51822;
in
{
  networking.firewall.allowedUDPPorts = [ port ];
  age.secrets.dn42-peer-kioubit-wg-private = {
    file = ./wg-private.age;
    owner = "systemd-network";
    group = "systemd-network";
  };
  systemd.network = {
    enable = true;
    networks."70-dn42-kioubit" = {
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
            Address = "fe80::ade1/64";
          };
        }
      ];
    };
    netdevs."70-dn42-kioubit" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = iface;
      };
      wireguardConfig = {
        PrivateKeyFile = config.age.secrets.dn42-peer-kioubit-wg-private.path;
        ListenPort = port;
      };
      wireguardPeers = [
        {
          wireguardPeerConfig = {
            PublicKey = "B1xSG/XTJRLd+GrWDsB06BqnIq8Xud93YVh/LYYYtUY=";
            Endpoint = "de2.g-load.eu:23085";
            AllowedIPs = [ "fe80::/64" "fd00::/8" ];
          };
        }
      ];
    };
  };
}
