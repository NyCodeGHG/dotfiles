{ config, lib, pkgs, ... }:
let
  port = 51820;
in
{
  environment.systemPackages = [
    pkgs.wireguard-tools
  ];
  networking = {
    nat.enable = true;
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
            {
              name = "pixel";
              publicKey = "bbeNjsvKgB/5TCeQ8zZw2cOUuVIp0UYyeNYmfyxKLDM=";
              allowedIPs = [ "10.69.0.4/32" ];
              persistentKeepalive = 25;
            }
            {
              name = "marie-desktop";
              publicKey = "Xr0evEh5CYykgaiXQJDt4P62rjPJXoV40Kz+yGykfEQ=";
              allowedIPs = [ "10.69.0.5/32" ];
              persistentKeepalive = 25;
            }
            {
              name = "firetv";
              publicKey = "ix5kGyVlSASM0EruH3kzZtMwd0QJ0Ar8v6IIs24Jzzo=";
              allowedIPs = [ "10.69.0.6/32" ];
              persistentKeepalive = 25;
            }
            {
              name = "delphi";
              publicKey = "qj6y6xfFtYga5hpT8FygOAOKN0xIDO5+sdtT8K2ozUc=";
              allowedIPs = [ "10.69.0.7/32" ];
              # persistentKeepalive is not needed here, because we're not behind nat
            }
            {
              name = "tobi-nas";
              publicKey = "aFMhUNLlj6oF3iDqUdlcJR1sxVjjRSDJ1S8bcH+fwhA=";
              allowedIPs = [ "10.69.0.8/32" "192.168.178.0/24" ];
              persistentKeepalive = 25;
            }
          ];
        };
      };
    };
    nftables = {
      enable = true;
    };
  };
}
