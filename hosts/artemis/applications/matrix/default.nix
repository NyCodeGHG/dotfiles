{ config, lib, pkgs, ... }:
let
  serverName = "marie.cologne";
  matrixDomain = "matrix.marie.cologne";
  frontendDomain = "chat.marie.cologne";
  clientConfig."m.homeserver".base_url = "https://${matrixDomain}";
  serverConfig."m.server" = "${matrixDomain}:443";
  mkWellKnown = data: ''
    add_header Content-Type application/json;
    add_header Access-Control-Allow-Origin *;
    return 200 '${builtins.toJSON data}';
  '';
in
{
  uwumarie.reverse-proxy.services = {
    "${serverName}" = {
      locations."/" = {
        return = "418";
      };
      locations."= /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;
      locations."= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;
    };
    "${matrixDomain}" = {
      locations."/" = {
        return = "301 https://${frontendDomain}";
      };
      locations."/_matrix".proxyPass = "http://[::1]:8008";
      locations."/_synapse/client".proxyPass = "http://[::1]:8008";
    };
    "${frontendDomain}" = {
      locations."/" = {
        root = pkgs.cinny.override {
          conf = {
            defaultHomeserver = 0;
            homeserverList = [
              "marie.cologne"
            ];
            allowCustomHomeservers = false;
          };
        };
      };
    };
  };

  services.postgresql = {
    ensureUsers = [
      {
        name = "matrix-synapse";
        ensurePermissions = {
          "DATABASE \"matrix-synapse\"" = "ALL PRIVILEGES";
        };
      }
    ];
    ensureDatabases = [ "matrix-synapse" ];
  };

  services.matrix-synapse = {
    enable = true;
    settings = {
      server_name = serverName;
      enable_registration = false;
      public_baseurl = "https://${matrixDomain}/";
      database = {
        name = "psycopg2";
        args = {
          # Bug in NixOS module this only triggers that the local db is used
          host = "127.0.0.1";
          database = "matrix-synapse";
          user = "matrix-synapse";
        };
      };
      listeners = [
        {
          port = 8008;
          bind_addresses = [ "::1" ];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = [ "client" "federation" ];
              compress = false;
            }
          ];
        }
      ];
    };
    extraConfigFiles = [
      (pkgs.writeText
        "postgres.yaml"
        ''
          database:
            name: psycopg2
            args:
              host: /run/postgresql
              database: matrix-synapse
              user: matrix-synapse
        '')
    ];
  };
}
