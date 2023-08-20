{ ... }:
{
  services.jellyfin.enable = true;
  services.nginx.virtualHosts."jellyfin.marie.cologne" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:8096";
      proxyWebsockets = true;
      extraConfig = ''
        allow 127.0.0.1/24;
        allow 10.69.0.1/24;
        deny all;
      '';
    };
  };
}
