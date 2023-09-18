{ config, self, ... }:
{
  services.minio = {
    enable = true;
    region = "eu-frankfurt";
    rootCredentialsFile = config.age.secrets.minio.path;
  };
  services.nginx.virtualHosts = {
    "minio.marie.cologne" = {
      serverAliases = [ "cdn.marie.cologne" ];
      locations."/" = {
        proxyPass = "http://127.0.0.1${config.services.minio.listenAddress}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_connect_timeout 300;
          proxy_set_header Connection "";
          chunked_transfer_encoding off;
        '';
      };
      locations."/ui/" = {
        proxyPass = "http://127.0.0.1${config.services.minio.consoleAddress}";
        proxyWebsockets = true;
        extraConfig = ''
          rewrite ^/ui/(.*) /$1 break;
          proxy_set_header X-NginX-Proxy true;
        '';
      };
      extraConfig = ''
        client_max_body_size 1000m;
        ignore_invalid_headers off;
        proxy_buffering off;
        proxy_request_buffering off;
      '';
    };
  };
  systemd.services.minio.environment = {
    MINIO_SERVER_URL = "https://minio.marie.cologne";
    MINIO_BROWSER_REDIRECT_URL = "https://minio.marie.cologne/ui";
  };
  age.secrets.minio.file = "${self}/secrets/minio.age";
}
