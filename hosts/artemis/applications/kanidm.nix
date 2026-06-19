{ config, pkgs, ... }:
let
  domain = "idm.marie.cologne";
in
{
  services.kanidm = {
    package = pkgs.kanidm_1_10;

    client = {
      enable = true;
      settings.uri = "https://${domain}";
    };

    server = {
      enable = true;
      settings = {
        inherit domain;
        origin = "https://${domain}";
        tls_chain = "/var/lib/acme/${domain}/fullchain.pem";
        tls_key = "/var/lib/acme/${domain}/key.pem";
        http_client_address_info.x-forward-for = [ "::1" ];
        bindaddress = "[::1]:8443";
      };
    };
  };
  security.acme.certs."${domain}" = {
    postRun = "systemctl restart kanidm.service";
    group = "kanidm";
  };

  services.nginx.virtualHosts."${domain}" = {
    locations."/" = {
      proxyPass = "https://${toString config.services.kanidm.server.settings.bindaddress}";
      extraConfig = ''
        proxy_ssl_verify on;
        proxy_ssl_trusted_certificate /etc/ssl/certs/ca-certificates.crt;
        proxy_ssl_name ${domain};
        proxy_ssl_verify_depth 3;
      '';
    };
  };
}
