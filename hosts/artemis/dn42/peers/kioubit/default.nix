{
  pkgs,
  config,
  lib,
  ...
}:
{
  dn42.peers.kioubit = {
    self.wireguard = {
      port = 51822;
      interface = "dn42n1";
      linkLocalAddress = "fe80::ade1/64";
      privateKeySecret = ./wg-private.age;
    };
    peer.asn = 4242423914;
    peer.wireguard = {
      linkLocalAddress = "fe80::ade0";
      publicKey = "B1xSG/XTJRLd+GrWDsB06BqnIq8Xud93YVh/LYYYtUY=";
      endpoint = "de2.g-load.eu:23085";
    };
  };
}
