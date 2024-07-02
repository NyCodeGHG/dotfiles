{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.uwumarie.services.authentik;
in
{
  options = {
    uwumarie.services.authentik = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enables the authentik service.
        '';
      };
      environmentFiles = mkOption {
        type = with types; listOf path;
        default = [ ];
        description = ''
          Environment files for the containers.
        '';
      };
      id = mkOption {
        type = types.int;
        default = 181350;
        description = ''
          ID used for the unix user and group.
        '';
      };
      ldap = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Enables the deployment of an LDAP outpost.
          '';
        };
        environmentFiles = mkOption {
          type = with types; listOf path;
          default = [ ];
          description = ''
            Environment files for the ldap outpost container.
          '';
        };
      };
      redis = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Weither to enable and use the local redis service.
          '';
        };
        host = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = ''
            The redis host to use.
          '';
        };
        port = mkOption {
          type = types.port;
          default = 6379;
          description = ''
            The redis port to use.
          '';
        };
        database = mkOption {
          type = types.int;
          default = 0;
          description = ''
            The redis database to use.
          '';
        };
      };
      postgres = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Enable the usage and configuration of the local postgresql database.
          '';
        };
        host = mkOption {
          type = types.str;
          default = "/run/postgresql";
          description = ''
            The postgres host to use.
          '';
        };
        port = mkOption {
          type = types.port;
          default = 5432;
          description = ''
            The postgres port to use.
          '';
        };
        database = mkOption {
          type = types.str;
          default = "authentik";
          description = ''
            The database to use.
          '';
        };
      };
      extraEnv = mkOption {
        type = with types; attrsOf str;
        default = { };
        description = ''
          Extra environment variables for the authentik server.
        '';
      };
      nginx = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Enable virtual host in nginx.
          '';
        };
        domain = mkOption {
          type = types.str;
          description = ''
            Domain for the service.
          '';
        };
        extraConfig = mkOption {
          type = types.attrs;
          default = { };
          description = ''
            Extra options for the nginx virtual host.
          '';
        };
      };
    };
  };

  config =
    let
      image = "ghcr.io/goauthentik/server:2024.6.0";
      ldapImage = "ghcr.io/goauthentik/ldap:2024.6.0";
      mkAuthentikContainer =
        { cmd ? [ ]
        , dependsOn ? [ ]
        , mountPostgres ? true
        , image
        , environmentFiles ? cfg.environmentFiles
        , env ? {
            AUTHENTIK_REDIS__HOST = cfg.redis.host;
            AUTHENTIK_REDIS__PORT = builtins.toString cfg.redis.port;
            AUTHENTIK_REDIS__DB = builtins.toString cfg.redis.database;
            AUTHENTIK_POSTGRESQL__HOST = cfg.postgres.host;
            AUTHENTIK_POSTGRESQL__PORT = builtins.toString cfg.postgres.port;
            AUTHENTIK_POSTGRESQL__NAME = cfg.postgres.database;
          }
        ,
        }: {
          inherit cmd dependsOn image environmentFiles;
          environment = env // cfg.extraEnv;
          extraOptions = [
            "--network=host"
          ];
          volumes = mkIf mountPostgres [
            "/run/postgresql:/run/postgresql:ro"
            "/var/lib/authentik/media:/media"
          ];
          user = "${builtins.toString cfg.id}:${builtins.toString cfg.id}";
        };
    in
    mkIf cfg.enable
      {
        assertions = [
          {
            assertion = config.virtualisation.podman.enable;
            message = "Authentik Service is only supported on podman.";
          }
        ];

        virtualisation.oci-containers.containers = {
          authentik-server = mkAuthentikContainer {
            cmd = [ "server" ];
            inherit image;
          };
          authentik-worker = mkAuthentikContainer {
            cmd = [ "worker" ];
            dependsOn = [ "authentik-server" ];
            inherit image;
          };
          authentik-ldap = mkIf cfg.ldap.enable (mkAuthentikContainer {
            mountPostgres = false;
            dependsOn = [ "authentik-server" ];
            image = ldapImage;
            environmentFiles = cfg.ldap.environmentFiles;
            env = {
              AUTHENTIK_HOST = "http://127.0.0.1:9000";
              AUTHENTIK_INSECURE = "false";
            };
          });
        };

        systemd.services.podman-authentik-server = {
          after = [ "network-online.target" "postgresql.service" ];
          wants = [ "network-online.target" "postgresql.service" ];
          requires = [ "postgresql.service" ];
        };

        systemd.services.podman-authentik-worker = {
          after = [ "network-online.target" "postgresql.service" ];
          wants = [ "network-online.target" "postgresql.service" ];
          requires = [ "postgresql.service" ];
        };

        services.postgresql = mkIf cfg.postgres.enable {
          enable = true;
          ensureDatabases = [
            "authentik"
          ];
          ensureUsers = [
            {
              name = "authentik";
              ensureDBOwnership = true;
            }
          ];
        };

        services.redis.servers."" = mkIf cfg.redis.enable {
          enable = true;
        };

        users = {
          users.authentik = {
            isSystemUser = true;
            group = "authentik";
            uid = cfg.id;
            home = "/var/lib/authentik";
            createHome = true;
          };
          groups.authentik = {
            gid = cfg.id;
          };
        };

        systemd.tmpfiles.rules = [
          "d /var/lib/authentik/media 0740 authentik authentik -"
        ];

        services.nginx = mkIf cfg.nginx.enable {
          enable = true;
          upstreams.authentik = {
            servers = { "127.0.0.1:9000" = { }; };
            extraConfig = ''
              keepalive 10;
            '';
          };
          virtualHosts.${cfg.nginx.domain} = cfg.nginx.extraConfig // {
            locations."/" = {
              proxyPass = "http://authentik";
              proxyWebsockets = true;
            };
          };
        };
      };
}
