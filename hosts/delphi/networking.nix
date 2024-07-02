{ config, lib, pkgs, ... }:
let
  port = 51820;
in
{
  environment.systemPackages = with pkgs; [ wireguard-tools ];
  networking = {
    hostName = "delphi";
    nftables.enable = true;
    firewall = {
      enable = true;
      extraInputRules = ''
        iifname wg0 ip saddr 10.69.0.0/24 tcp dport { 9100, 3031 } accept
      '';
      allowedUDPPorts = [ port ];
      allowedTCPPorts = [ 80 443 ];
    };
    nameservers = [
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
      "1.1.1.1"
      "1.0.0.1"
    ];
    useNetworkd = true;
    useDHCP = false;
  };
  systemd.network = {
    enable = true;
    networks = {
      "10-ethernet" = {
        matchConfig.Type = [ "ether" ];
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
          KeepConfiguration = "yes";
        };
      };
      "50-wg0" = {
        name = "wg0";
        address = [ "10.69.0.7/24" "fdf1:3ba4:9723:2000::1/64" ];
        networkConfig.KeepConfiguration = "yes";
      };
    };
    netdevs."50-wg0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
      };
      wireguardConfig = {
        PrivateKeyFile = config.age.secrets.delphi-wg-privatekey.path;
        ListenPort = port;
        RouteTable = "main";
      };
      wireguardPeers = [
        {
          # artemis
          wireguardPeerConfig = {
            PublicKey = "cIsemKHaYdTw/ki2RP3AfmYSx3f1G0ejent4N0yFDlg=";
            AllowedIPs = [ "10.69.0.0/24" "fd00::/8" ];
            Endpoint = "89.58.10.36:51820";
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
      ];
    };
  };

  age.secrets.delphi-wg-privatekey = {
    file = ../../secrets/delphi-wg-privatekey.age;
    owner = "systemd-network";
    group = "systemd-network";
  };
}
