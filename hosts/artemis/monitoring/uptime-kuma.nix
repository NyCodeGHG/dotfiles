{ ... }:
{
  services.uptime-kuma = {
    enable = true;
    appriseSupport = true;
  };
  services.nginx.tailscaleAuth = {
    enable = true;
    virtualHosts = [ "uptime-kuma.marie.cologne" ];
  };
  services.nginx.virtualHosts = {
    "uptime-kuma.marie.cologne" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:3001";
        proxyWebsockets = true;
      };
    };
    "status.marie.cologne" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:3001";
        proxyWebsockets = true;
      };
    };
  };
}
