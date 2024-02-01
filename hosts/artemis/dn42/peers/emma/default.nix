{ pkgs, config, lib, ... }:
{
  dn42.peers.emma = {
    self.wireguard = {
      port = 51821;
      interface = "dn42n0";
      linkLocalAddress = "fe80::d56f:a7fc:c62d:b88a/64";
      privateKeySecret = ./wg-private.age;
    };
    peer.asn = 4242423161;
    peer.wireguard = {
      linkLocalAddress = "fe80::d119:602d:d206:e469";
      publicKey = "6IgFC2JAZ0xjZhDaH3YxpruFtMkoEPralJXzctBCnyA=";
      endpoint = "2a03:4000:47:251:::51821";
    };
  };
}
