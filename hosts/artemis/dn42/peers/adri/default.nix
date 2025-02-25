{ ... }:
{
  dn42.peers.adri = {
    self.wireguard = {
      port = 51824;
      interface = "dn42n3";
      linkLocalAddress = "fe80::fe86/64";
      privateKeySecret = ./wg-private.age;
    };
    peer.asn = 4242423963;
    peer.wireguard = {
      linkLocalAddress = "fe80::4d21";
      publicKey = "ivs00nKBI/YaMAEPVpvaRTw1nV9iGYtFdc1ANYkfp2Q=";
      endpoint = "heinz.apnt.dev:56172";
    };
  };
}
