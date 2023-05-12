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
        extraLocationConfig = mkOption {
          type = types.attrs;
          default = { };
          description = ''
            Extra options for the nginx virtual host location.
          '';
        };
      };
    };
  };

  config =
    let
      mkImage = { name, tag, sha256, digest }: {
        name = "${name}:${tag}";
        image = pkgs.dockerTools.pullImage {
          imageName = name;
          imageDigest = digest;
          inherit sha256;
          finalImageName = name;
          finalImageTag = tag;
        };
      };
      authentik = mkImage {
        name = "ghcr.io/goauthentik/server";
        tag = "2023.4.1";
        digest = "sha256:96c9f29247a270524056aff59f1bcb7118ef51d14b334b67ab2b75e8df30e829";
        sha256 = "1n412yncv7a890nq0lzvcs6w0nihs2bmqdzg5hs95dyq42gbric4";
      };
      mkAuthentikContainer =
        { cmd
        , dependsOn ? [ ]
        ,
        }: {
          inherit cmd dependsOn;
          imageFile = authentik.image;
          image = authentik.name;
          environment = {
            AUTHENTIK_REDIS__HOST = cfg.redis.host;
            AUTHENTIK_REDIS__PORT = builtins.toString cfg.redis.port;
            AUTHENTIK_REDIS__DB = builtins.toString cfg.redis.database;
            AUTHENTIK_POSTGRESQL__HOST = cfg.postgres.host;
            AUTHENTIK_POSTGRESQL__PORT = builtins.toString cfg.postgres.port;
            AUTHENTIK_POSTGRESQL__NAME = cfg.postgres.database;
          } // cfg.extraEnv;
          extraOptions = [
            "--network=host"
            "--pull=never"
          ];
          volumes = [
            "/run/postgresql:/run/postgresql:ro"
          ];
          environmentFiles = cfg.environmentFiles;
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
          };
          authentik-worker = mkAuthentikContainer {
            cmd = [ "worker" ];
            dependsOn = [ "authentik-server" ];
          };
        };

        services.postgresql = mkIf cfg.postgres.enable {
          enable = true;
          ensureDatabases = [
            "authentik"
          ];
          ensureUsers = [
            {
              name = "authentik";
              ensurePermissions = {
                "DATABASE authentik" = "ALL PRIVILEGES";
              };
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
          };
          groups.authentik = {
            gid = cfg.id;
          };
        };

        services.nginx = mkIf cfg.nginx.enable {
          enable = true;
          upstreams.authentik = {
            servers = { "127.0.0.1:9000" = { }; };
            extraConfig = ''
              keepalive 10;
            '';
          };
          virtualHosts.${cfg.nginx.domain} = {
            locations."/" = {
              proxyPass = "http://authentik";
              proxyWebsockets = true;
            } // cfg.nginx.extraLocationConfig;
          } // cfg.nginx.extraConfig;
        };
      };
}
