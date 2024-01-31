{ ... }:
{
  services.nginx = {
    enable = true;
    virtualHosts."marie.dn42" = {
      useACMEHost = "marie.dn42";
      locations."/.well-known/acme-challenge" = {
        root = "/var/lib/acme/acme-challenge/";
      };
    };
  };
  security.acme.certs."marie.dn42" = {
    domain = "marie.dn42";
    dnsProvider = null;
    group = "nginx";
    webroot = "/var/lib/acme/acme-challenge";
    server = "https://acme.burble.dn42/v1/dn42/acme/directory";
    validMinDays = 7;
  };
}
