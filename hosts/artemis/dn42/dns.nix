{ ... }:
{
  services.coredns = {
    enable = true;
    config = ''
      marie.dn42 {
          prometheus
          log
          errors
          file ${./db.marie.dn42}
          bind dn42
      }
    '';
  };
}
