{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.uwumarie.services.coder;
in
{
  options = {
    uwumarie.services.coder = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enables the coder service.
        '';
      };
      accessUrl = mkOption {
        type = types.str;
        default = "";
        description = ''
          Access URL for coder.
        '';
      };
      wildcardUrl = mkOption {
        type = types.str;
        default = "";
        description = ''
          Wildcard Access URL for coder.
        '';
      };
      port = mkOption {
        type = types.port;
        default = 4040;
        description = ''
          Port to use for coder.
        '';
      };
      extraEnvironment = mkOption {
        type = types.attrs;
        default = { };
        description = ''
          Extra environment variables.
        '';
      };
      environmentFiles = mkOption {
        type = with types; listOf path;
        default = [ ];
        description = ''
          Environment files for the container.
        '';
      };
      nginx = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Configure nginx for proxying coder.
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

  config = mkIf cfg.enable {
    virtualisation.podman.enable = true;
    services.postgresql = {
      enable = true;
      ensureDatabases = [ "coder" ];
      initialScript = pkgs.writeText "backend-initScript" ''
        CREATE ROLE coder WITH LOGIN PASSWORD 'coder' CREATEDB;
        CREATE DATABASE coder;
        GRANT ALL PRIVILEGES ON DATABASE coder TO coder;
      '';
    };
    virtualisation.oci-containers = {
      backend = "podman";
      containers.coder = {
        image = "ghcr.io/coder/coder:v2.1.5";
        extraOptions = [
          "--network=host"
        ];
        volumes = [
          "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
        ];
        user = "root";
        environmentFiles = cfg.environmentFiles;
        environment = {
          CODER_HTTP_ADDRESS = "127.0.0.1:${builtins.toString cfg.port}";
          CODER_ACCESS_URL = cfg.accessUrl;
          CODER_WILDCARD_ACCESS_URL = cfg.wildcardUrl;
          CODER_TELEMETRY = "false";
          CODER_PG_CONNECTION_URL = "postgres://coder:coder@localhost/coder?sslmode=disable";
        } // cfg.extraEnvironment;
      };
    };
    services.nginx = mkIf cfg.nginx.enable {
      enable = true;
      upstreams.coder = {
        servers = { "127.0.0.1:${builtins.toString cfg.port}" = { }; };
      };
      virtualHosts.${
      lib.strings.removePrefix "http://" (lib.strings.removePrefix "https://" cfg.accessUrl)
      } = cfg.nginx.extraConfig // {
        serverAliases = [ cfg.wildcardUrl ];
        locations."/" = {
          proxyPass = "http://coder";
          proxyWebsockets = true;
        };
      };
    };
  };
}
