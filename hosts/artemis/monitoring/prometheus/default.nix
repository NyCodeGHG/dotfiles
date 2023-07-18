{ pkgs, config, lib, ... }: {
  imports = [
    ./alertmanager.nix
  ];
  services.prometheus = {
    enable = true;
    retentionTime = "15d";
    webExternalUrl = "https://prometheus.marie.cologne";
    exporters = {
      node.enable = true;
    };
    ruleFiles = [
      (pkgs.writeText "prometheus-rules.yml" (builtins.toJSON {
        groups = [
          {
            name = "alerting-rules";
            rules = import ./rules.nix { inherit lib; };
          }
        ];
      }))
    ];
    awesome-prometheus-alerts = {
      prometheus-self-monitoring.embedded-exporter.enable = true;
    };
    globalConfig.scrape_interval = "30s";
    scrapeConfigs = 
    let
      mkTarget = { target, job, instance ? config.networking.hostName }: {
        job_name = job;
        static_configs = [
          {
            targets = [target];
            labels = {
              inherit instance;
            };
          }
        ];
      };
    in [
      (mkTarget {
        job = "prometheus";
        target = "localhost:${toString config.services.prometheus.port}";
      })
      (mkTarget {
        job = "node-exporter";
        target = "localhost:${toString config.services.prometheus.exporters.node.port}";
      })
      (mkTarget {
        job = "loki";
        target = "localhost:${toString config.services.loki.configuration.server.http_listen_port}";
      })
      (mkTarget {
        job = "tempo";
        target = "localhost:${toString config.services.tempo.settings.server.http_listen_port}";
      })
      (mkTarget {
        job = "grafana";
        target = "localhost:${toString config.services.grafana.settings.server.http_port}";
      })
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