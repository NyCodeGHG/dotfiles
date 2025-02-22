{ ... }:
{
  networking = {
    hostName = "marie-nas";
    useDHCP = false;
    nftables.enable = true;
    firewall.allowedTCPPorts = [ 80 443 ];
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

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  services.resolved = {
    enable = true;
    extraConfig = 
    ''
      MulticastDNS=false
    '';
  };
}
