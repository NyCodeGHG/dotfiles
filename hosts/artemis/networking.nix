{ ... }:
{
 networking = {
    hostName = "artemis";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 ];
    };
    nftables.enable = true;
    interfaces = {
      ens3.ipv6.addresses = [
        {
          address = "2a03:4000:5f:f5b::";
          prefixLength = 64;
        }
      ];
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "ens3";
    };
  };
}