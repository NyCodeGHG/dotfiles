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

      . {
        bind lo wg0
        import base


        forward . tls://2620:fe::fe tls://2620:fe::9 tls://9.9.9.9 tls://149.112.112.112 {
          tls_servername dns.quad9.net
          health_check 5s
          except dn42 d.f.ip6.arpa ts.net
        }

        forward dn42 fd42:d42:d42:54::1 fd42:d42:d42:53::1
        forward d.f.ip6.arpa fd42:d42:d42:54::1 fd42:d42:d42:53::1
        forward ts.net 100.100.100.100

        cache 30
      }
    '';
  };
  networking.resolvconf = {
    enable = true;
    useLocalResolver = true;
  };
}
