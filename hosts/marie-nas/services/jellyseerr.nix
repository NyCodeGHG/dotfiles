{ ... }:
{
  services.jellyseerr = {
    enable = true;
  };
  services.nginx.virtualHosts."jellyseerr.marie.cologne".locations."/" = {
    proxyPass = "http://127.0.0.1:5055";
    proxyWebsockets = true;
  };
}
