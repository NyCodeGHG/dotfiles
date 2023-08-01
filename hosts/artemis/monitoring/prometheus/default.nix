{ pkgs, config, lib, ... }: {
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
        enabledCollectors = [
          "network_route"
          "systemd"
        ];
      };
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
      host-and-hardware.node-exporter.enable = true;
      loki.embedded-exporter.enable = true;
      promtail.embedded-exporter.enable = true;
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
      {
        job_name = "node-exporter";
        static_configs = [
          {
            targets = ["localhost:${toString config.services.prometheus.exporters.node.port}"];
            labels = {
              instance = config.networking.hostName;
            };
          }
          {
            targets = ["10.69.0.7:9100"];
            labels = {
              instance = "delphi";
            };
          }
        ];
      }
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
      {
        job_name = "promtail";
        static_configs = [
          {
            targets = ["localhost:${toString config.services.promtail.configuration.server.http_listen_port}"];
            labels = {
              instance = config.networking.hostName;
            };
          }
          {
            targets = ["10.69.0.7:3031"];
            labels = {
              instance = "delphi";
            };
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
