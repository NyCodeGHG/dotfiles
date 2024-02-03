{ config, self, ... }: {
  imports = [
    ./alertmanager.nix
  ];
  services.prometheus = {
    enable = true;
    retentionTime = "15d";
    webExternalUrl = "https://prometheus.marie.cologne";
    exporters = {
      node = {
        enable = true;
        # Enable additional collectors
        enabledCollectors = [ "systemd" ];
        disabledCollectors = [
          "fibrechannel"
          "hwmon"
          "infiniband"
          "thermal_zone"
          "xfs"
          "zfs"
        ];
      };
    };
    globalConfig.scrape_interval = "30s";
    scrapeConfigs =
      let
        mkTarget = { target, job, instance ? config.networking.hostName }: {
          job_name = job;
          static_configs = [
            {
              targets = [ target ];
              labels = {
                inherit instance;
              };
            }
          ];
        };
      in
      [
        (mkTarget {
          job = "prometheus";
          target = "localhost:${toString config.services.prometheus.port}";
        })
        {
          job_name = "node-exporter";
          static_configs = [
            {
              targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
              labels = {
                instance = config.networking.hostName;
              };
            }
            {
              targets = [ "10.69.0.7:9100" ];
              labels = {
                instance = "delphi";
              };
            }
          ];
        }
        (mkTarget {
          job = "grafana";
          target = "localhost:${toString config.services.grafana.settings.server.http_port}";
        })
        (mkTarget {
          job = "ip-playground";
          target = "127.0.0.1:3032";
        })
        # (mkTarget {
        #   job = "unifiedmetrics";
        #   target = "10.69.0.7:9101";
        # })
      ];
  };

  services.nginx.virtualHosts."prometheus.marie.cologne" = {
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
}
