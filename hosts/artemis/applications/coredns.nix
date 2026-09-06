{ ... }:
{
  services.coredns = {
    enable = true;
    config = ''
      (base) {
        prometheus
        errors
      }
      (dn42) {
        bind dn42
        import base
      }
      marie.dn42 {
        file ${../dn42/db.marie.dn42}
        import dn42
      }
      3.2.7.9.4.a.b.3.1.f.d.f.ip6.arpa {
        file ${../dn42/db.reverse-dns}
        import dn42
      }
    '';
  };
}
