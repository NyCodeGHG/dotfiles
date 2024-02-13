{ pkgs, config, lib, ... }:
{
  dn42.peers.maraun = {
    self.wireguard = {
      port = 51823;
      interface = "dn42n2";
      linkLocalAddress = "fe80::c5b8/64";
      privateKeySecret = ./wg-private.age;
    };
    peer.asn = 4242422225;
    peer.wireguard = {
      linkLocalAddress = "fe80::3085";
      publicKey = "uS1AYe7zTGAP48XeNn0vppNjg7q0hawyh8Y0bvvAWhk=";
      endpoint = "2a03:4000:6:75c8:e83a:fcff:fe08:956f:23085";
    };
  };
}
