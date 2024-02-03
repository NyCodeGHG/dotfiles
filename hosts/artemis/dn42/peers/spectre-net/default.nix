{ pkgs, config, lib, ... }:
{
  dn42.peers.spectre-net = {
    self.wireguard = {
      port = 51823;
      interface = "dn42n2";
      linkLocalAddress = "fe80::4bc1/64";
      privateKeySecret = ./wg-private.age;
    };
    peer.asn = 0;
    peer.wireguard = {
      linkLocalAddress = "";
      publicKey = "";
      endpoint = "";
    };
  };
}
