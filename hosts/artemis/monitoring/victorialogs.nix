{ ... }:
{
  services.victorialogs.enable = true;

  services.nginx.virtualHosts."logs.artemis.marie.cologne" = {
    locations."/" = {
      proxyPass = "http://localhost:9428";
      proxyWebsockets = true;
    };
  };
  services.nginx.tailscaleAuth = {
    enable = true;
    virtualHosts = [ "logs.artemis.marie.cologne" ];
  };

  services.journald.upload = {
    enable = true;
    settings = {
      Upload.URL = "http://localhost:9428/insert/journald";
    };
  };
}
