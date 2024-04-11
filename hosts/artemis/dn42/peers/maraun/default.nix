{ pkgs, config, lib, ... }:
{
  dn42.peers.maraun = {
    self.wireguard = {
      port = 51823;
      interface = "dn42n2";
      linkLocalAddress = "fe80::7bdd/64";
      privateKeySecret = ./wg-private.age;
    };
    peer.asn = 4242422225;
    peer.wireguard = {
      linkLocalAddress = "fe80::2225";
      publicKey = "uS1AYe7zTGAP48XeNn0vppNjg7q0hawyh8Y0bvvAWhk=";
      endpoint = "dn42-de.maraun.de:23085";
    };
  };
}
