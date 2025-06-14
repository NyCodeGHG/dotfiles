{ ... }:
{
  networking = {
    hostName = "delphi";
    nftables.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
      ];
    };
    useNetworkd = true;
    useDHCP = false;
  };
  systemd.network = {
    enable = true;
    networks = {
      "10-ethernet" = {
        matchConfig = {
          Type = [ "ether" ];
          Kind = [ "!veth" ];
        };
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
          KeepConfiguration = "yes";
        };
      };
    };
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };
}
