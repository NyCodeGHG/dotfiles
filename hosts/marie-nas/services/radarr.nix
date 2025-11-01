{ config, ... }:
{
  services.radarr = {
    enable = true;
    group = "media";
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
      "radarr-main"
      "radarr-log"
    ];
    ensureUsers = [
      {
        name = "radarr";
      }
    ];
  };

  systemd.services.radarr = {
    wants = [
      "postgresql.target"
      "radarr-postgresql-setup.service"
    ];
    after = [
      "postgresql.target"
      "radarr-postgresql-setup.service"
    ];
  };

  systemd.services.radarr-postgresql-setup = {
    description = "Sonarr PostgreSQL setup";
    after = [ "postgresql.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      Group = "postgres";
      ExecStart = [
        "${config.services.postgresql.package}/bin/psql -c 'ALTER DATABASE \"radarr-log\" OWNER TO \"radarr\";'"
        "${config.services.postgresql.package}/bin/psql -c 'ALTER DATABASE \"radarr-main\" OWNER TO \"radarr\";'"
      ];
    };
  };

  services.nginx.virtualHosts."radarr.marie.cologne" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.radarr.settings.server.port}";
      proxyWebsockets = true;
    };
    locations."/api" = {
      # extra entry to bypass oauth2-proxy
      proxyPass = "http://127.0.0.1:${toString config.services.radarr.settings.server.port}";
      proxyWebsockets = true;
      extraConfig = ''
        auth_request off;
      '';
    };
  };
}
