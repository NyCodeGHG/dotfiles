{
  pkgs,
  config,
  inputs,
  ...
}:
{
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
      blackbox = {
        enable = true;
        configFile = ./blackbox-exporter.yaml;
      };
      json = {
        enable = true;
        configFile = (pkgs.formats.yaml { }).generate "json-exporter-config.yml" {
          # thanks k900
          modules.matrix-federation.metrics = [
            {
              name = "matrix_homeserver_federation_ok";
              path = "{.FederationOK}";
              help = "False if there's any problem with federation reported.";
              type = "value";
              value_type = "gauge";
            }
          ];
        };
      };
    };
    globalConfig.scrape_interval = "30s";
    scrapeConfigs =
      let
        mkTarget =
          {
            target,
            job,
            instance ? config.networking.hostName,
          }:
          {
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
            {
              targets = [ "marie-nas:9100" ];
              labels.instance = "marie-nas";
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
        (mkTarget {
          job = "blackbox-exporter";
          target = "127.0.0.1:${toString config.services.prometheus.exporters.blackbox.port}";
        })
        {
          job_name = "blackbox-http";
          metrics_path = "/probe";
          params.module = [ "http_2xx" ];
          relabel_configs = [
            {
              source_labels = [ "__address__" ];
              target_label = "__param_target";
            }
            {
              source_labels = [ "__param_target" ];
              target_label = "instance";
            }
            {
              target_label = "__address__";
              replacement = "127.0.0.1:${toString config.services.prometheus.exporters.blackbox.port}";
            }
          ];
          static_configs = [
            {
              targets = [
                "https://sso.nycode.dev/-/health/live/"
                "https://git.marie.cologne/"
                "https://grafana.marie.cologne/"
                "https://ip.marie.cologne"
                "https://miniflux.marie.cologne/"
              ];
            }
          ];
        }
        {
          job_name = "blackbox-icmp";
          metrics_path = "/probe";
          params.module = [ "icmp" ];
          relabel_configs = [
            {
              source_labels = [ "__address__" ];
              target_label = "__param_target";
            }
            {
              source_labels = [ "__param_target" ];
              target_label = "instance";
            }
            {
              target_label = "__address__";
              replacement = "127.0.0.1:${toString config.services.prometheus.exporters.blackbox.port}";
            }
          ];
          static_configs = [
            {
              targets = [
                "vpn.wg.techtoto.dev"
                "10.69.0.8"
                "delphi"
                "gitlabber"
              ];
            }
          ];
        }
        # thanks k900
        {
          job_name = "matrix-federation";
          metrics_path = "/probe";
          params.module = [ "matrix-federation" ];
          relabel_configs = [
            {
              source_labels = [ "__address__" ];
              target_label = "__param_target";
            }
            {
              source_labels = [ "__address__" ];
              target_label = "instance";
            }
            {
              target_label = "__address__";
              replacement = "localhost:${toString config.services.prometheus.exporters.json.port}";
            }
          ];
          static_configs = [
            {
              targets = [ "https://federationtester.matrix.org/api/report?server_name=marie.cologne" ];
              labels.matrix_instance = "marie.cologne";
            }
          ];
        }
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
