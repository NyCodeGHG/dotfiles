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
        {
          address = "2a03:4000:005f:0f5b:b00b:1337:cafe:4269";
          prefixLength = 128;
        }
      ];
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "ens3";
    };
  };
}