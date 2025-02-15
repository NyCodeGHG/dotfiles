{ config, ... }:
{
  services.changedetection-io = {
    enable = true;
    behindProxy = true;
    webDriverSupport = false;
    playwrightSupport = false;
    baseURL = "https://cdio.marie.cologne";
  };
  services.nginx.virtualHosts."cdio.marie.cologne".locations."/" = {
    proxyPass = "http://127.0.0.1:${toString config.services.changedetection-io.port}";
    proxyWebsockets = true;
  };
  services.nginx.tailscaleAuth = {
    enable = true;
    virtualHosts = [ "cdio.marie.cologne" ];
  };
}
