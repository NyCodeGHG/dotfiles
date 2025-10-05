{ pkgs, config, ... }:
{
  services.garage = {
    enable = true;
    package = pkgs.garage_2;
    settings = {
      db_engine = "sqlite";
      replication_factor = 1;
      rpc_bind_addr = "[::]:3901";
      s3_api = {
        s3_region = "garage";
        api_bind_addr = "[::]:3900";
      };
      admin = {
        api_bind_addr = "[::]:3903";
      };
    };
  };

  systemd.services.garage = {
    serviceConfig = {
      LoadCredential = [
        "rpc-secret:${config.age.secrets.garage-rpc-secret.path}"
      ];
    };
    environment = {
      # Not enabled on 25.05
      # GARAGE_LOG_TO_JOURNALD = "true";
      GARAGE_RPC_SECRET_FILE = "%d/rpc-secret";
      GARAGE_ALLOW_WORLD_READABLE_SECRETS = "true";
    };
  };
  age.secrets.garage-rpc-secret.file = ../secrets/garage-rpc-secret.age;

  services.nginx.virtualHosts."s3.marie.cologne" = {
    locations."/" = {
      proxyPass = "http://[::1]:3900";
    };
    extraConfig = ''
      client_max_body_size 8000M;
      proxy_request_buffering off;
      proxy_read_timeout 600s;
    '';
  };
}
