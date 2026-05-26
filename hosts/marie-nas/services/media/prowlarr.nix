{ config, ... }:
{
  services.prowlarr = {
    enable = true;
    settings = {
      auth = {
        method = "External";
        type = "DisabledForLocalAddresses";
      };
      log = {
        analyticsEnabled = false;
      };
      postgres = {
        host = "/run/postgresql";
      };
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [
      "prowlarr-main"
      "prowlarr-log"
    ];
    ensureUsers = [
      {
        name = "prowlarr";
      }
    ];
  };

  systemd.services.prowlarr = {
    wants = [
      "postgresql.target"
      "prowlarr-postgresql-setup.service"
    ];
    after = [
      "postgresql.target"
      "prowlarr-postgresql-setup.service"
    ];
  };

  systemd.services.prowlarr-postgresql-setup = {
    description = "Prowlarr PostgreSQL setup";
    after = [ "postgresql.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      Group = "postgres";
      ExecStart = [
        "${config.services.postgresql.package}/bin/psql -c 'ALTER DATABASE \"prowlarr-log\" OWNER TO \"prowlarr\";'"
        "${config.services.postgresql.package}/bin/psql -c 'ALTER DATABASE \"prowlarr-main\" OWNER TO \"prowlarr\";'"
      ];
    };
  };

  services.nginx.virtualHosts."prowlarr.marie.cologne".locations."/" = {
    proxyPass = "http://127.0.0.1:9696";
    proxyWebsockets = true;
  };
}
