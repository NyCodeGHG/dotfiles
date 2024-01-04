{ ... }:
{
  systemd.network = {
    enable = true;
    networks."10-ens3" = {
      name = "ens3";
      DHCP = "no";
      networkConfig = {
        DNSOverTLS = "opportunistic";
        DNSSEC = "allow-downgrade";
      };
      dns = [
        # Netcup
        "2a03:4000:0:1::e1e6"
        "2a03:4000:8000::fce6"
        "46.38.225.230"
        "46.38.252.230"
        # Cloudflare
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
        "1.1.1.1"
        "1.0.0.1"
        # Google
        "2001:4860:4860::8888"
        "2001:4860:4860::8844"
        "8.8.8.8"
        "8.8.4.4"
      ];
      address = [
        "89.58.10.36/22"
        "2a03:4000:5f:f5b::/64"
      ];
      routes = [
        { routeConfig.Gateway = "89.58.8.1"; }
        { routeConfig.Gateway = "fe80::1"; }
      ];
    };
  };

  networking = {
    hostName = "artemis";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 ];
      logRefusedConnections = false;
      pingLimit = "2/minute burst 5 packets";
      # Allow Loki access from Wireguard
      interfaces.wg0.allowedTCPPorts = [
        3030
      ];
    };
    nftables.enable = true;
    useDHCP = false;
  };
  boot.kernel.sysctl = {
    "net.ipv6.conf.default.accept_ra" = 0;
    "net.ipv6.conf.default.autoconf" = 0;
    "net.ipv6.conf.all.accept_ra" = 0;
    "net.ipv6.conf.all.autoconf" = 0;
    "net.ipv6.conf.ens3.accept_ra" = 0;
    "net.ipv6.conf.ens3.autoconf" = 0;
  };
}
