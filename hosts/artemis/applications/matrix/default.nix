{ config, lib, pkgs, inputs, ... }:
let
  serverName = "marie.cologne";
  matrixDomain = "matrix.marie.cologne";
  frontendDomain = "chat.marie.cologne";
  clientConfig."m.homeserver".base_url = "https://${matrixDomain}";
  clientConfig."m.identity_server".base_url = "https://vector.im";
  serverConfig."m.server" = "${matrixDomain}:443";
  mkWellKnown = data: ''
    add_header Content-Type application/json;
    add_header Access-Control-Allow-Origin *;
    return 200 '${builtins.toJSON data}';
  '';
  backgrounds = pkgs.callPackage ./backgrounds.nix { };
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
      locations."~ ^(/_matrix|/_synapse/client)" = {
        proxyPass = "http://[::1]:8008";
        extraConfig = ''
          client_max_body_size 50M;
          proxy_http_version 1.1;
        '';
      };
    };
    "${frontendDomain}" =
      let headers = ''
        add_header X-Frame-Options SAMEORIGIN;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header Content-Security-Policy "frame-ancestors 'self'";
      '';
      in
      {
        locations."/" = {
          root = pkgs.element-web.override {
            conf = {
              default_server_config = clientConfig;
              default_country_code = "DE";
              room_directory.servers = [ "matrix.org" "mozilla.org" "skji.org" ];
              default_theme = "dark";
              default_device_display_name = "Element Web";
              permalink_prefix = "https://chat.marie.cologne";
              disable_guests = true;
              branding = {
                welcome_background_url = map (name: "/_backgrounds/${name}") (builtins.attrNames (builtins.readDir backgrounds));
              };
              logout_redirect_url = "https://sso.nycode.dev/application/o/synapse/end-session/";
              integrations_ui_url = "https://scalar.vector.im/";
              integrations_rest_url = "https://scalar.vector.im/api";
              integrations_widgets_urls = [
                "https://scalar.vector.im/_matrix/integrations/v1"
                "https://scalar.vector.im/api"
                "https://scalar-staging.vector.im/_matrix/integrations/v1"
                "https://scalar-staging.vector.im/api"
                "https://scalar-staging.riot.im/scalar/api"
              ];
              enable_presence_by_hs_url = {
                "https://matrix.org" = false;
                "https://matrix-client.matrix.org" = false;
              };
            };
          };
          extraConfig = headers;
        };
        locations."/_backgrounds" = {
          root = "${backgrounds}";
          tryFiles = "$uri =404";
          extraConfig = ''
            rewrite ^/_backgrounds/(.*) /$1 break;
            ${headers}
          '';
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
      enable_metrics = config.services.prometheus.enable;
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
        (lib.mkIf config.services.prometheus.enable {
          port = 8009;
          bind_addresses = [ "127.0.0.1" ];
          type = "metrics";
          tls = false;
          x_forwarded = false;
          resources = [ ];
        })
      ];
      password_config = {
        enabled = false;
      };
      sso = {
        client_whitelist = [
          "https://chat.marie.cologne"
        ];
        update_profile_information = true;
      };
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
      config.age.secrets.synapse-sso-config.path
    ];
  };
  systemd.services.matrix-synapse = {
    after = [ "network-online.target" "postgresql.service" "podman-authentik-server.service" ];
    wants = [ "network-online.target" "postgresql.service" "podman-authentik-server.service" ];
  };
  age.secrets.synapse-sso-config = {
    file = "${inputs.self}/secrets/synapse-sso-config.age";
    owner = "matrix-synapse";
  };
  services.prometheus.scrapeConfigs = [
    {
      job_name = "synapse";
      static_configs = [
        {
          targets = [ "127.0.0.1:8009" ];
        }
      ];
    }
  ];
}
