{ config, lib, pkgs, inputs, ... }:
let
  serverName = "marie.cologne";
  matrixDomain = "matrix.marie.cologne";
  frontendDomain = "chat.marie.cologne";
  clientConfig."m.homeserver".base_url = "https://${matrixDomain}";
  clientConfig."m.homeserver".server_name = "marie.cologne";
  clientConfig."m.identity_server".base_url = "https://vector.im";
  clientConfig."org.matrix.msc3575.proxy".url = "https://${matrixDomain}";
  serverConfig."m.server" = "${matrixDomain}:443";
  mkWellKnown = data: ''
    add_header Content-Type application/json;
    add_header Access-Control-Allow-Origin *;
    return 200 '${builtins.toJSON data}';
  '';
  backgrounds = pkgs.callPackage ./backgrounds.nix { };
in
{
  services.nginx.virtualHosts = {
    "${serverName}" = {

      locations."= /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;
      locations."= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;
    };
    "${matrixDomain}" = {
      locations."= /" = {
        return = "301 https://${frontendDomain}";
      };
      locations."~ ^/(client/|_matrix/client/unstable/org.matrix.msc3575/sync)" = {
        proxyPass = "http://[::1]:8009";
        extraConfig = ''
          client_max_body_size 50M;
          proxy_http_version 1.1;
        '';
      };
      locations."~ ^/(_matrix|_synapse)" = {
        proxyPass = "http://[::1]:8008";
        extraConfig = ''
          client_max_body_size 50M;
          proxy_http_version 1.1;
        '';
      };
      locations."/synapse-admin".root = pkgs.linkFarm "synapse-admin-routing" [{
        name = "synapse-admin";
        path = "${pkgs.synapse-admin}";
      }];
    };
    "${frontendDomain}" =
      let
        headers = ''
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
    extras = [ "oidc" ];
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
          port = 8010;
          bind_addresses = [ "127.0.0.1" ];
          type = "metrics";
          tls = false;
          x_forwarded = false;
          resources = [ ];
        })
      ];
      password_config = {
        enabled = true;
      };
      sso = {
        client_whitelist = [
          "https://chat.marie.cologne"
        ];
        update_profile_information = true;
      };
      turn_user_lifetime = "1h";
      turn_allow_guests = false;
      turn_uris = [
        "turn:turn.marie.cologne:3478?transport=udp"
        "turn:turn.marie.cologne:3478?transport=tcp"
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
      config.age.secrets.synapse-sso-config.path
      config.age.secrets.turn-secret-synapse-config.path
    ];
    # sliding-sync = {
    #   enable = true;
    #   environmentFile = config.age.secrets.matrix-sliding-sync.path;
    #   settings = {
    #     SYNCV3_SERVER = "https://matrix.marie.cologne";
    #     SYNCV3_BINDADDR = "[::]:8009";
    #   };
    # };
  };
  systemd.services.matrix-synapse = {
    after = [ "network-online.target" "postgresql.service" "podman-authentik-server.service" ];
    wants = [ "network-online.target" "postgresql.service" "podman-authentik-server.service" ];
    startLimitIntervalSec = 500;
    startLimitBurst = 20;
    serviceConfig = {
      Restart = lib.mkForce "on-failure";
      RestartSec = lib.mkForce 10;
    };
  };
  age.secrets.synapse-sso-config = {
    file = "${inputs.self}/secrets/synapse-sso-config.age";
    owner = "matrix-synapse";
  };
  age.secrets.turn-secret-synapse-config = {
    file = "${inputs.self}/secrets/turn-secret-synapse-config.age";
    owner = "matrix-synapse";
    # rekeyFile = "${inputs.self}/secrets/turn-secret-synapse-config.age";
    # generator = {
    #   dependencies = [
    #     inputs.self.nixosConfigurations.delphi.config.age.secrets.turn-secret
    #   ];
    #   script = { pkgs, lib, decrypt, deps, ... }:
    #   let
    #     turn-secret = builtins.head deps;
    #   in
    #     ''
    #       echo "turn_shared_secret: \"$(${decrypt} ${lib.escapeShellArg turn-secret.file})\""
    #     '';
    # };
  };
  # age.secrets.matrix-sliding-sync.file = "${inputs.self}/secrets/matrix-sliding-sync.age";
  services.prometheus.scrapeConfigs = [
    {
      job_name = "synapse";
      static_configs = [
        {
          targets = [ "127.0.0.1:8010" ];
        }
      ];
    }
  ];
}
