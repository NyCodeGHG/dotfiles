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

        forward . tls://1.1.1.1 tls://1.0.0.1 tls://2606:4700:4700::1111 tls://2606:4700:4700::1001 {
          tls_servername cloudflare-dns.com
          health_check 5s
          except dn42 d.f.ip6.arpa
        }

        forward dn42 fd42:d42:d42:54::1 fd42:d42:d42:53::1
        forward d.f.ip6.arpa fd42:d42:d42:54::1 fd42:d42:d42:53::1
        cache 30

        acl dn42. {
          filter type A
        }
      }
    '';
  };
  networking.resolvconf = {
    enable = true;
    useLocalResolver = true;
  };
}
