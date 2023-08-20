{ config, ... }:
{
  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 3031;
        grpc_listen_port = 0;
      };
      positions = {
        filename = "/tmp/positions.yaml";
      };
      clients = [
        {
          url = "http://10.69.0.1:3030/loki/api/v1/push";
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
