{
  system.installer.channel.enable = false;

  security.sudo-rs.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    startWhenNeeded = false;
  };

  networking = {
    useDHCP = false;
    # allow bpg
    firewall.allowedTCPPorts = [ 179 ];
  };

  systemd.network = {
    enable = true;
    networks = {
      "80-ethernet" = {
        matchConfig = {
          Type = [ "ether" ];
          Kind = [ "!veth bridge tap tun" ];
        };
        linkConfig = {
          RequiredForOnline = "routable";
        };
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
          MulticastDNS = "resolve";
        };
      };
    };
    config = {
      networkConfig = {
        SpeedMeter = true;
        IPv6PrivacyExtensions = false;
      };
    };
  };
}
