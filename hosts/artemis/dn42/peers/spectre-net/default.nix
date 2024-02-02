{ pkgs, config, lib, ... }:
let
  iface = "dn42n2";
  port = 51823;
in
{
  networking.firewall.allowedUDPPorts = [ port ];
  age.secrets.dn42-peer-spectre-net-wg-private = {
    file = ./wg-private.age;
    owner = "systemd-network";
    group = "systemd-network";
  };
  systemd.network = {
    enable = true;
    networks."70-dn42-spectre-net" = {
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
            Address = "fe80::4bc1/64";
          };
        }
      ];
    };
    netdevs."70-dn42-spectre-net" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = iface;
      };
      wireguardConfig = {
        PrivateKeyFile = config.age.secrets.dn42-peer-spectre-net-wg-private.path;
        ListenPort = port;
      };
      wireguardPeers = [
        # {
        #   wireguardPeerConfig = {
        #     PublicKey = "";
        #     AllowedIPs = [ "fe80::/64" "fd00::/8" ];
        #   };
        # }
      ];
    };
  };
}
