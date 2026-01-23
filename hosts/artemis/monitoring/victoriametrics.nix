{ ... }:
{
  services.victoriametrics = {
    enable = true;
    retentionPeriod = "30d";
    prometheusConfig = {
      global = {
        scrape_interval = "30s";
        scrape_timeout = "10s";
      };
      scrape_configs = [
        {
          job_name = "untis-caldav-sync";
          metrics_path = "/metrics";
          static_configs = [
            {
              targets = [ "localhost:3002" ];
              labels.environment = "staging";
            }
          ];
        }
      ];
    };
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
