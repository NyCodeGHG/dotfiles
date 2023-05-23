{ config, lib, pkgs, ... }:
let
  port = 51820;
in
{
  environment.systemPackages = [
    pkgs.wireguard-tools
  ];
  networking = {
    nat = {
      enable = true;
      externalInterface = "ens3";
      internalInterfaces = [ "wg0" ];
    };
    firewall = {
      allowedUDPPorts = [ port ];
      trustedInterfaces = [ "wg0" ];
    };
    wireguard = {
      enable = true;
      interfaces = {
        wg0 = {
          ips = [ "10.69.0.1/24" ];
          listenPort = port;
          privateKeyFile = "/root/wireguard-keys/private";
          peers = [
            {
              name = "marie";
              publicKey = "EAmQtnK3a8uSQZtV0x7+f3dxl2PnqKeYl1EclQaeBBY=";
              allowedIPs = [ "10.69.0.2/32" ];
              persistentKeepalive = 25;
            }
            {
              name = "raspberrypi";
              publicKey = "8XzwNX81oK3gXbOLcgLmYyxqZCz4K9HEfDUCbWfuegg=";
              allowedIPs = [ "10.69.0.3/32" ];
              persistentKeepalive = 25;
            }
          ];
        };
      };
    };
  };
}
