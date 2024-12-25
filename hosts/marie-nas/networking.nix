{ ... }:
{
  networking = {
    hostName = "marie-nas";
    useDHCP = false;
    nftables.enable = true;
  };
  systemd.network = {
    enable = true;
    networks = {
      ethernet = {
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
    useRoutingFeatures = "both";
  };
}
