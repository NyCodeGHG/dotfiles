{ pkgs, config, lib, ... }:
let
  inherit (lib) mkOption types mkMerge mapAttrs' nameValuePair mapAttrsToList;
  peers = config.dn42.peers;
in
{
  options.dn42.peers = mkOption {
    description = "dn42 peers";
    type = with types; attrsOf (submodule {
      options = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable this peer";
        };
        name = mkOption {
          type = with types; nullOr str;
          default = null;
          description = "Name of the peer. Defaults to the attribute name";
        };
        self = {
          wireguard = {
            linkLocalAddress = mkOption {
              type = types.str;
              description = "Our ipv6 link local address for the wireguard interface";
            };
            privateKeySecret = mkOption {
              type = types.path;
              description = "Path to the agenix encrypted wireguard private key file";
            };
            interface = mkOption {
              type = types.str;
              description = "Interface name for this peer";
            };
            port = mkOption {
              type = types.port;
              description = "Port to open for the peer to connect to";
            };
          };
        };
        peer.asn = mkOption {
          type = types.int;
          description = "The peers as number";
        };
        peer.wireguard = {
          linkLocalAddress = mkOption {
            type = types.str;
            description = "The peers ipv6 link local address";
          };
          publicKey = mkOption {
            type = types.str;
            description = "The peers wireguard public key";
          };
          endpoint = mkOption {
            type = types.str;
            description = "The peers wireguard endpoint";
          };
          allowedIPs = mkOption {
            type = with types; listOf str;
            default = [ "fe80::/64" "fd00::/8" ];
          };
        };
      };
    });
  };
  config = {
    networking.firewall.allowedUDPPorts = mapAttrsToList (_: conf: conf.self.wireguard.port) peers;
    systemd.network = {
      enable = true;

      networks = mapAttrs'
        (name: conf: nameValuePair "70-dn42-${name}" {
          name = conf.self.wireguard.interface;
          DHCP = "no";
          networkConfig = {
            IPv6AcceptRA = false;
            IPForward = "yes";
            KeepConfiguration = "yes";
          };
          addresses = [
            { addressConfig.Address = conf.self.wireguard.linkLocalAddress; }
          ];
        })
        peers;

      netdevs = mapAttrs'
        (name: conf: nameValuePair "70-dn42-${name}" {
          netdevConfig = {
            Kind = "wireguard";
            Name = conf.self.wireguard.interface;
          };
          wireguardConfig = {
            PrivateKeyFile = config.age.secrets."dn42-peer-${name}-wg-private".path;
            ListenPort = conf.self.wireguard.port;
          };
          wireguardPeers = [
            {
              wireguardPeerConfig = {
                PublicKey = conf.peer.wireguard.publicKey;
                Endpoint = conf.peer.wireguard.endpoint;
                AllowedIPs = conf.peer.wireguard.allowedIPs;
              };
            }
          ];
        })
        peers;
    };

    age.secrets = mapAttrs'
      (name: conf: nameValuePair "dn42-peer-${name}-wg-private" {
        file = conf.self.wireguard.privateKeySecret;
        owner = "systemd-network";
        group = "systemd-network";
      })
      peers;
  };
}
