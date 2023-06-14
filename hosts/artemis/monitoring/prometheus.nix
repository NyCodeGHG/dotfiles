{ config, lib, pkgs, ... }: {
  services.prometheus = {
    enable = true;
    retentionTime = "15d";
    webExternalUrl = "https://prometheus.marie.cologne";
    exporters = {
      node.enable = true;
    };
    globalConfig.scrape_interval = "30s";
    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [
          {
            targets = [ "localhost:${toString config.services.prometheus.port}" ];
          }
        ];
      }
      {
        job_name = "node-exporter";
        static_configs = [
          {
            targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
          }
        ];
      }
    ];
  };
  uwumarie.reverse-proxy.services = {
    "prometheus.marie.cologne" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.prometheus.port}";
        proxyWebsockets = true;
        extraConfig = ''
          allow 127.0.0.1/24;
          allow 10.69.0.1/24;
          deny all;
        '';
      };
    };
  };
}
