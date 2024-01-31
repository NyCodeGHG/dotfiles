{ ... }:
{
  services.coredns = {
    enable = true;
    config = ''
      (snip) {
        prometheus
        log
        errors
        bind dn42
      }
      marie.dn42 {
          file ${./db.marie.dn42}
          import snip
      }
      3.2.7.9.4.a.b.3.1.f.d.f.ip6.arpa {
          file ${./db.reverse-dns}
          import snip
      }
    '';
  };
}
