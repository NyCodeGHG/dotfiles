{ ... }:
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
    ensureUsers = [{
      name = "prowlarr";
    }];
  };

  systemd.services.postgresql.postStart = ''
    $PSQL -tAc 'ALTER DATABASE "prowlarr-log" OWNER TO "prowlarr";'
    $PSQL -tAc 'ALTER DATABASE "prowlarr-main" OWNER TO "prowlarr";'
  '';

  services.nginx.virtualHosts."prowlarr.marie.cologne".locations."/" = {
    proxyPass = "http://127.0.0.1:9696";
    proxyWebsockets = true;
  };
}
