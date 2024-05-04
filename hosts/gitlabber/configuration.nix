{ pkgs, config, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/minimal.nix")
  ];
  networking.useDHCP = false;
  services.resolved.enable = false;
  uwumarie.profiles = {
    nspawn = true;
    openssh = true;
  };

  environment.systemPackages = with pkgs; [ wireguard-tools ];

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
        address = [
          "2a03:4000:5f:f5b:8596:a039:73f9:f2bf/128"
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
          PrivateKeyFile = config.age.secrets.wg0-private.path;
          RouteTable = "main";
        };
        wireguardPeers = [
          {
            # artemis
            wireguardPeerConfig = {
              PublicKey = "ph9Pg7QVjZtuWYScyYWBkIgbROcFUSK0JDly/sY+3lQ=";
              AllowedIPs = [ "2000::/3" ];
              PersistentKeepalive = 25;
              Endpoint = "89.58.10.36:52020";
            };
          }
        ];
      };
    };
  };

  age.secrets.wg0-private = {
    file = ./secrets/wg0-private.age;
    owner = "systemd-network";
    group = "systemd-network";
  };

  system.stateVersion = "23.11";
  nixpkgs.hostPlatform = "x86_64-linux";
}
