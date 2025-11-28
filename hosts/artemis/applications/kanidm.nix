{ config, pkgs, ... }:
let
  domain = "idm.marie.cologne";
in
{
  services.kanidm = {
    enableClient = true;
    clientSettings = {
      uri = "https://${domain}";
    };

    package = pkgs.kanidm_1_8;

    enableServer = true;
    serverSettings = {
      inherit domain;
      origin = "https://${domain}";
      tls_chain = "/var/lib/acme/${domain}/fullchain.pem";
      tls_key = "/var/lib/acme/${domain}/key.pem";
      trust_x_forward_for = true;
      bindaddress = "[::1]:8443";
    };
  };
  security.acme.certs."${domain}" = {
    postRun = "systemctl restart kanidm.service";
    group = "kanidm";
  };

  services.nginx.virtualHosts."${domain}" = {
    locations."/" = {
      proxyPass = "https://${toString config.services.kanidm.serverSettings.bindaddress}";
      extraConfig = ''
        proxy_ssl_verify on;
        proxy_ssl_trusted_certificate /etc/ssl/certs/ca-certificates.crt;
        proxy_ssl_name ${domain};
      '';
    };
  };
}
