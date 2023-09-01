{ config, self, ... }:
{
  imports = [
    "${self}/modules/pgrok.nix"
  ];
  services.pgrok = {
    enable = true;
    settings = {
      external_url = "https://tunnel.marie.cologne";
      web = {
        port = 3320;
      };
      proxy = {
        port = 3070;
        scheme = "http";
        domain = "tunnel.marie.cologne";
      };
      sshd = {
        port = 2222;
      };
      database = {
        host = "/run/postgresql";
        user = "pgrok";
        port = 5432;
        database = "pgrok";
      };
      identity_provider = {
        type = "oidc";
        display_name = "Authentik";
        issuer = "https://sso.nycode.dev/application/o/pgrok/";
        client_id = "wkG4JDxfWoK2QpJfYLadmuvWOJn8IEadLxQmaHOc";
        client_secret = { _secret = config.age.secrets.pgrok-client-secret.path; };
        field_mapping = {
          identifier = "lowercase_username";
          display_name = "name";
          email = "email";
        };
      };
    };
  };
  age.secrets.pgrok-client-secret = {
    file = "${self}/secrets/pgrok-client-secret.age";
    owner = config.services.pgrok.user;
    group = config.services.pgrok.group;
  };
  services.postgresql = {
    enable = true;
    ensureDatabases = [
      "pgrok"
    ];
    ensureUsers = [
      {
        name = "pgrok";
        ensurePermissions = {
          "DATABASE pgrok" = "ALL PRIVILEGES";
        };
      }
    ];
  };
  services.nginx.virtualHosts = {
    "tunnel.marie.cologne" = {
      useACMEHost = "tunnel.marie.cologne";
      locations."/" = {
        proxyPass = "http://127.0.0.1:3320";
      };
    };
    "*.tunnel.marie.cologne" = {
      useACMEHost = "tunnel.marie.cologne";
      locations."/" = {
        proxyPass = "http://127.0.0.1:3070";
      };
    };
  };
  security.acme.certs."tunnel.marie.cologne" = {
    domain = "tunnel.marie.cologne";
    extraDomainNames = [
      "*.tunnel.marie.cologne"
    ];
  };
  networking.firewall.allowedTCPPorts = [ 2222 ];
}
