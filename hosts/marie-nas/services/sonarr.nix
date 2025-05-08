{ config, ... }:
{
  services.sonarr = {
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
      "sonarr-main"
      "sonarr-log"
    ];
    ensureUsers = [{
      name = "sonarr";
    }];
  };

  systemd.services.postgresql.postStart = ''
    $PSQL -tAc 'ALTER DATABASE "sonarr-log" OWNER TO "sonarr";'
    $PSQL -tAc 'ALTER DATABASE "sonarr-main" OWNER TO "sonarr";'
  '';

  services.nginx.virtualHosts."sonarr.marie.cologne".locations."/" = {
    proxyPass = "http://127.0.0.1:${toString config.services.sonarr.settings.server.port}";
    proxyWebsockets = true;
  };
}
