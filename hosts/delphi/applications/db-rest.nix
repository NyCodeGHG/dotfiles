{ config, ... }:
{
  services.db-rest = {
    enable = true;
    redis.enable = true;
    port = 56456;
  };
  services.nginx.virtualHosts = {
    "db-rest.marie.cologne" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.db-rest.port}";
      };
    };
  };
}
