{ config, ... }:
let
  lokiPort = 3030;
  promtailPort = 3031;
in
{
  services.loki = {
    enable = true;
    configuration = {
      server.http_listen_port = lokiPort;
      auth_enabled = false;

      ingester = {
        lifecycler = {
          address = "127.0.0.1";
          ring = {
            kvstore = {
              store = "inmemory";
            };
            replication_factor = 1;
          };
        };
        chunk_idle_period = "1h";
        max_chunk_age = "1h";
        chunk_target_size = 999999;
        chunk_retain_period = "30s";
        max_transfer_retries = 0;
      };
      schema_config = {
        configs = [{
          from = "2023-05-22";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v12";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }];
      };

      storage_config = {
        tsdb_shipper = {
          active_index_directory = "/var/lib/loki/tsdb-index";
          cache_location = "/var/lib/loki/tsdb-cache";
          cache_ttl = "24h";
          shared_store = "filesystem";
        };

        filesystem = {
          directory = "/var/lib/loki/chunks";
        };
      };

      limits_config = {
        reject_old_samples = true;
        reject_old_samples_max_age = "168h";
        split_queries_by_interval = "24h";
        max_query_parallelism = 100;
      };

      query_scheduler = {
        max_outstanding_requests_per_tenant = 4096;
      };

      frontend = {
        max_outstanding_per_tenant = 4096;
      };

      chunk_store_config = {
        max_look_back_period = "0s";
      };

      table_manager = {
        retention_deletes_enabled = true;
        retention_period = "48h";
      };

      compactor = {
        working_directory = "/var/lib/loki";
        shared_store = "filesystem";
        compactor_ring = {
          kvstore = {
            store = "inmemory";
          };
        };
      };

      ruler = {
        enable_api = true;
        enable_alertmanager_v2 = true;
        ring.kvstore.store = "inmemory";
        rule_path = "/var/lib/loki/rules-temp";
        alertmanager_url = "http://127.0.0.1:${toString config.services.prometheus.alertmanager.port}";
        storage = {
          type = "local";
          local.directory = "/var/lib/loki/rules";
        };
      };
    };
  };

  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = promtailPort;
        grpc_listen_port = 0;
      };
      positions = {
        filename = "/tmp/positions.yaml";
      };
      clients = [
        {
          url = "http://127.0.0.1:${toString lokiPort}/loki/api/v1/push";
        }
      ];
      scrape_configs = [
        {
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels = {
              job = "systemd-journal";
              host = config.networking.hostName;
            };
          };
          relabel_configs = [
            {
              source_labels = [ "__journal__systemd_unit" ];
              target_label = "unit";
            }
          ];
        }
        {
          job_name = "nginx";
          static_configs = [
            {
              targets = [ "localhost" ];
              labels = {
                __path__ = "/var/log/nginx/json_access.log";
                host = config.networking.hostName;
                job = "nginx";
              };
            }
          ];
        }
      ];
    };
  };
  users.users.promtail.extraGroups = [ "nginx" ];
}
