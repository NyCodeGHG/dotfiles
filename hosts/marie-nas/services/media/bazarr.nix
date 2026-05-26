{ config, ... }:
{
  services.bazarr = {
    enable = true;
    group = "media";
  };
  services.nginx.virtualHosts."bazarr.marie.cologne" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.bazarr.listenPort}";
      proxyWebsockets = true;
    };
  };
}
