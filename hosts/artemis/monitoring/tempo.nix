{ ... }:
{
  services.tempo = {
    enable = true;
    settings = {
      server = {
        http_listen_port = 3200;
        grpc_listen_port = 9096;
      };
      storage = {
        trace = {
          backend = "local";
          wal = {
            path = "/var/lib/tempo/wal";
          };
          local = {
            path = "/var/lib/tempo/blocks";
          };
        };
      };
      distributor = {
        receivers = {
          otlp = {
            protocols = {
              grpc = {};
              http = {};
            };
          };
        };
      };
    };
  };
}