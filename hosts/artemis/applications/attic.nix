{ config, ... }:
{
  age.secrets.attic.file = ../secrets/attic.age;
  services.atticd = {
    enable = true;
    environmentFile = config.age.secrets.attic.path;
    settings = {
      listen = "127.0.0.1:54678";
      allowed-hosts = [ "cache.marie.cologne" ];
      api-endpoint = "https://cache.marie.cologne/";
      soft-delete-caches = false;
      require-proof-of-possession = true;
      database.url = "postgresql:///atticd";
      storage = {
        type = "s3";
        region = "auto";
        bucket = "attic";
        endpoint = "https://82758a83eb971497ed2c8171439a1ad5.r2.cloudflarestorage.com";
      };
      compression = {
        type = "zstd";
        level = 8;
      };
      garbage-collection = {
        interval = "1 day";
        default-retention-period = "3 months";
      };
      chunking = {
        nar-size-threshold = 64 * 1024;
        min-size = 16 * 1024;
        avg-size = 64 * 1024;
        max-size = 256 * 1024;
      };
    };
  };
  services.postgresql = {
    enable = true;
    ensureDatabases = [
      "atticd"
    ];
    ensureUsers = [
      {
        name = "atticd";
        ensureDBOwnership = true;
      }
    ];
  };
  services.nginx.virtualHosts."cache.marie.cologne" = {
    locations."/" = {
      proxyPass = "http://${config.services.atticd.settings.listen}";
    };
    extraConfig = ''
      client_max_body_size 8000M;
      proxy_request_buffering off;
      proxy_read_timeout 600s;
    '';
  };
}
