{ config, ... }: {
  services.prometheus = {
    enable = true;
    retentionTime = "30d";
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
      bird.enable = true;
    };
    globalConfig.scrape_interval = "30s";
    scrapeConfigs =
      let
        mkTarget = { target, job, instance ? config.networking.hostName }: {
          job_name = job;
          static_configs = [
            {
              targets = [ target ];
              labels = { inherit instance; };
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
              labels.instance = config.networking.hostName;
            }
            {
              targets = [ "delphi:9100" ];
              labels.instance = "delphi";
            }
          ];
        }
        (mkTarget {
          job = "ip-playground";
          target = "127.0.0.1:3032";
        })
        (mkTarget {
          job = "bird";
          target = "127.0.0.1:${toString config.services.prometheus.exporters.bird.port}";
        })
      ];
  };

  services.nginx.virtualHosts."prometheus.marie.cologne" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.prometheus.port}";
      proxyWebsockets = true;
    };
  };
  services.nginx.tailscaleAuth = {
    enable = true;
    virtualHosts = [ "prometheus.marie.cologne" ];
  };
}
