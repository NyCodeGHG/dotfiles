{ config, pkgs, ... }:
let
  image = "ghcr.io/goauthentik/server:2026.8.0";
  volumes = [
    "/run/postgresql:/run/postgresql:ro"
    "/var/lib/authentik/media:/media"
  ];
  environment = {
    AUTHENTIK_POSTGRESQL__HOST = "/run/postgresql";
    AUTHENTIK_POSTGRESQL__NAME = "authentik";
  };
  environmentFiles = [ config.age.secrets.authentik-secrets.path ];
  uid = 181350;
  user = "${toString uid}:${toString uid}";
in
{
  virtualisation.oci-containers.containers = {
    authentik-server = {
      cmd = [ "server" ];
      inherit
        image
        volumes
        environment
        environmentFiles
        user
        ;
      ports = [ "127.0.0.1:9000:9000" ];
    };
    authentik-worker = {
      cmd = [ "worker" ];
      inherit
        image
        volumes
        environment
        environmentFiles
        user
        ;
      dependsOn = [ "authentik-server" ];
    };
  };

  age.secrets.authentik-secrets.file = ./secrets.age;

  services.postgresql = {
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

  users = {
    users.authentik = {
      isSystemUser = true;
      group = "authentik";
      inherit uid;
      home = "/var/lib/authentik";
      createHome = true;
    };
    groups.authentik = {
      gid = uid;
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/authentik/media 0740 authentik authentik -"
  ];

  systemd.services = {
    podman-authentik-server = {
      after = [
        "network-online.target"
        "postgresql.service"
      ];
      wants = [
        "network-online.target"
        "postgresql.service"
      ];
    };
    podman-authentik-worker = {
      after = [
        "network-online.target"
        "postgresql.service"
      ];
      wants = [
        "network-online.target"
        "postgresql.service"
      ];
    };
  };

  services.nginx = {
    enable = true;
    additionalModules = [ pkgs.nginxModules.njs ];
    upstreams.authentik = {
      servers = {
        "127.0.0.1:9000" = { };
      };
      extraConfig = ''
        keepalive 10;
      '';
    };
    commonHttpConfig = ''
      proxy_cache_path /var/cache/nginx/ keys_zone=cache:10m;
      js_import authentik from ${./authentik.js};
    '';
    virtualHosts."sso.nycode.dev" = {
      locations."/" = {
        proxyPass = "http://authentik";
        proxyWebsockets = true;
      };
      locations."@authentik" = {
        proxyPass = "http://authentik";
        proxyWebsockets = true;
      };
      locations."~* /application/o/[\\w\\-_]+/\\.well-known/openid-configuration$" = {
        extraConfig = ''
          proxy_cache cache;
          proxy_cache_use_stale error timeout http_500 http_502 http_503 http_504;
          proxy_cache_lock on;
          proxy_cache_valid 200 10m;
          add_header X-Cache-Status $upstream_cache_status;
          proxy_pass http://authentik;
        '';
      };
      locations."/application/o/authorize/" = {
        extraConfig = ''
          js_content authentik.cleanLoginHint;
        '';
      };
      extraConfig = ''
        error_page 401 /sso_unavailable.html;

        location = /sso_unavailable.html {
          root ${./nginx};
          internal;
        }
      '';
    };
  };
}
