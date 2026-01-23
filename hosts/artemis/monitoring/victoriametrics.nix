{ ... }:
{
  services.victoriametrics = {
    enable = true;
    retentionPeriod = "30d";
  };

  services.nginx.tailscaleAuth = {
    enable = true;
    virtualHosts = [ "metrics.artemis.marie.cologne" ];
  };

  services.nginx.virtualHosts."metrics.artemis.marie.cologne" = {
    locations."/" = {
      proxyPass = "http://localhost:8428";
      proxyWebsockets = true;
    };
  };
}
