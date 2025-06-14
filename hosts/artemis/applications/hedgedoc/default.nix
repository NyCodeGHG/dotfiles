{ config, ... }:
{
  services.hedgedoc = {
    enable = true;
    settings = {
      port = 6973;
      domain = "hedgedoc.marie.cologne";
      db = {
        username = "hedgedoc";
        database = "hedgedoc";
        host = "/run/postgresql";
        dialect = "postgresql";
      };
      protocolUseSSL = true;
      email = false;
    };
    environmentFile = config.age.secrets.hedgedoc-env.path;
  };
  services.postgresql = {
    enable = true;
    ensureDatabases = [
      "hedgedoc"
    ];
    ensureUsers = [
      {
        name = "hedgedoc";
        ensureDBOwnership = true;
      }
    ];
  };
  services.nginx = {
    enable = true;
    virtualHosts."hedgedoc.marie.cologne" = {
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.hedgedoc.settings.port}";
      };
    };
  };
  age.secrets.hedgedoc-env.file = ./env.age;
}
