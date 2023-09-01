{ lib, pkgs, config, modulesPath, ... }:
let
  php = pkgs.php;
  cfg = config.services.traewelling;
  inherit (cfg) user group;
  traewelling = cfg.package.override { inherit (cfg) dataDir runtimeDir; };
  configFile = pkgs.writeText "traewelling-env" (lib.generators.toKeyValue { } cfg.settings);
  traewelling-manage = pkgs.writeShellScriptBin "traewelling-manage" ''
    cd ${traewelling}
    sudo=exec
    if [[ "$USER" != ${user} ]]; then
      sudo='exec /run/wrappers/bin/sudo -u ${user}'
    fi
    $sudo ${php}/bin/php artisan "$@"
  '';
  dbSocket = {
    "pgsql" = "/run/postgresql";
    "mysql" = "/run/mysqld/mysqld.sock";
  }.${cfg.database.type};
  dbService = {
    "pgsql" = "postgresql.service";
    "mysql" = "mysql.service";
  }.${cfg.database.type};
  redisService = "redis-traewelling.service";
in
{
  options.services.traewelling = {
    enable = lib.mkEnableOption "traewelling";

    user = lib.mkOption {
      type = lib.types.str;
      default = "traewelling";
      description = lib.mdDoc ''
        User account under which traewelling runs.

        ::: {.note}
        If left as the default value this user will automatically be created
        on system activation, otherwise you are responsible for
        ensuring the user exists before the traewelling application starts.
        :::
      '';
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "traewelling";
      description = lib.mdDoc ''
          Group account under which traewelling runs.

          ::: {.note}
          If left as the default value this group will automatically be created
          on system activation, otherwise you are responsible for
          ensuring the group exists before the traewelling application starts.
          :::
      '';
    };

    package = lib.mkOption {
      type = lib.types.package;
    };

    domain = lib.mkOption {
      type = lib.types.str;
      description = lib.mdDoc ''
        FQDN for the Traewelling instance.
      '';
    };

    secretFile = lib.mkOption {
      type = lib.types.path;
      description = lib.mdDoc ''
        A secret file to be sourced for the .env settings.
        Place `APP_KEY` and other settings that should not end up in the Nix store here.
      '';
    };

    settings = lib.mkOption {
      type = with lib.types; (attrsOf (oneOf [ bool int str ]));
      description = lib.mdDoc ''
        .env settings for Traewelling.
        Secrets should use `secretFile` option instead.
      '';
    };

    nginx = lib.mkOption {
      type = lib.types.nullOr (lib.types.submodule
        (import "${modulesPath}/services/web-servers/nginx/vhost-options.nix" {
          inherit config lib;
        }));
      default = null;
      example = lib.literalExpression ''
        {
          serverAliases = [
            "travel.''${config.networking.domain}"
          ];
          enableACME = true;
          forceHttps = true;
        }
      '';
      description = lib.mdDoc ''
        With this option, you can customize an nginx virtual host which already has sensible defaults for Traewelling.
        Set to {} if you do not need any customization to the virtual host.
        If enabled, then by default, the {option}`serverName` is
        `''${domain}`,
        If this is set to null (the default), no nginx virtualHost will be configured.
      '';
    };

    redis.createLocally = lib.mkEnableOption
      (lib.mdDoc "a local Redis database using UNIX socket authentication")
      // {
        default = true;
      };

    database = {
      createLocally = lib.mkEnableOption
        (lib.mdDoc "a local database using UNIX socket authentication") // {
          default = true;
        };
      automaticMigrations = lib.mkEnableOption
        (lib.mdDoc "automatic migrations for database schema and data") // {
          default = true;
        };

      type = lib.mkOption {
        type = lib.types.enum [ "mysql" "pgsql" ];
        example = "pgsql";
        default = "mysql";
        description = lib.mdDoc ''
          Database engine to use.
        '';
      };

      name = lib.mkOption {
        type = lib.types.str;
        default = "traewelling";
        description = lib.mdDoc "Database name.";
      };
    };

    maxUploadSize = lib.mkOption {
      type = lib.types.str;
      default = "8M";
      description = lib.mdDoc ''
        Max upload size with units.
      '';
    };

    poolConfig = lib.mkOption {
      type = with lib.types; attrsOf (oneOf [ int str bool ]);
      default = { };

      description = lib.mdDoc ''
        Options for Traewelling's PHP-FPM pool.
      '';
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/traewelling";
      description = lib.mdDoc ''
        State directory of the `traewelling` user which holds
        the application's state and data.
      '';
    };

    runtimeDir = lib.mkOption {
      type = lib.types.str;
      default = "/run/traewelling";
      description = lib.mdDoc ''
        Ruutime directory of the `traewelling` user which holds
        the application's caches and temporary files.
      '';
    };

    schedulerInterval = lib.mkOption {
      type = lib.types.str;
      default = "5m";
      description = lib.mdDoc "How often the Traewelling cron task should run";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.traewelling = lib.mkIf (cfg.user == "traewelling") {
      isSystemUser = true;
      group = cfg.group;
      extraGroups = lib.optional cfg.redis.createLocally "redis-traewelling";
    };
    users.groups.traewelling = lib.mkIf (cfg.group == "traewelling") { };

    services.redis.servers.traewelling.enable = lib.mkIf cfg.redis.createLocally true;
    services.traewelling.settings = lib.mkMerge [
      ({
        APP_ENV = lib.mkDefault "production";
        APP_DEBUG = lib.mkDefault false;
        APP_URL = lib.mkDefault "https://${cfg.domain}";
        ADMIN_DOMAIN = lib.mkDefault cfg.domain;
        APP_DOMAIN = lib.mkDefault cfg.domain;
        SESSION_DOMAIN = lib.mkDefault cfg.domain;
        SESSION_SECURE_COOKIE = lib.mkDefault true;
        # Defer to systemd
        LOG_CHANNEL = lib.mkDefault "stderr";
      })
      (lib.mkIf (cfg.redis.createLocally) {
        BROADCAST_DRIVER = lib.mkDefault "redis";
        CACHE_DRIVER = lib.mkDefault "redis";
        QUEUE_DRIVER = lib.mkDefault "redis";
        SESSION_DRIVER = lib.mkDefault "redis";
        WEBSOCKET_REPLICATION_MODE = lib.mkDefault "redis";
        REDIS_SCHEME = "unix";
        REDIS_HOST = config.services.redis.servers.traewelling.unixSocket;
        REDIS_PATH = config.services.redis.servers.traewelling.unixSocket;
      })
      (lib.mkIf (cfg.database.createLocally) {
        DB_CONNECTION = cfg.database.type;
        DB_SOCKET = dbSocket;
        DB_DATABASE = cfg.database.name;
        DB_USERNAME = user;
        DB_PORT = 0;
      })
    ];
    environment.systemPackages = [ traewelling-manage ];

    services.mysql = 
      lib.mkIf (cfg.database.createLocally && cfg.database.type == "mysql") {
        enable = lib.mkDefault true;
        package = lib.mkDefault pkgs.mariadb;
        ensureDatabases = [ cfg.database.name ];
        ensureUsers = [{
            name = user;
            ensurePermissions = { "${cfg.database.name}.*" = "ALL PRIVILEGES"; };
        }];
      };

    services.postgresql = 
      lib.mkIf (cfg.database.createLocally && cfg.database.type == "pgsql") {
        enable = lib.mkDefault true;
        ensureDatabases = [ cfg.database.name ];
        ensureUsers = [{
          name = user;
          ensurePermissions = { };
        }];
      };

    # Make each individual option overridable with lib.mkDefault.
    services.traewelling.poolConfig = lib.mapAttrs' (n: v: lib.nameValuePair n (lib.mkDefault v)) {
      "pm" = "dynamic";
      "php_admin_value[error_log]" = "stderr";
      "php_admin_flag[log_errors]" = true;
      "catch_workers_output" = true;
      "pm.max_children" = "32";
      "pm.start_servers" = "2";
      "pm.min_spare_servers" = "2";
      "pm.max_spare_servers" = "4";
      "pm.max_requests" = "500";
    };

    services.phpfpm.pools.traewelling = {
      inherit user group;
      phpPackage = php;

      phpOptions = ''
        post_max_size = ${toString cfg.maxUploadSize}
        upload_max_filesize = ${toString cfg.maxUploadSize}
        max_execution_time = 600;
      '';
      
      settings = {
        "listen.owner" = user;
        "listen.group" = group;
        "listen.mode" = "0660";
        "catch_workers_output" = "yes";
      } // cfg.poolConfig;
    };

    systemd.services.phpfpm-traewelling.after = [ "traewelling-data-setup.service" ];
    systemd.services.phpfpm-traewelling.requires =
      [ /*"traewelling-horizon.service" */ "traewelling-data-setup.service" ]
      ++ lib.optional cfg.database.createLocally dbService
      ++ lib.optional cfg.redis.createLocally redisService;
  
    # systemd.services.traewelling-horizon = {
    #   description = "Traewelling task queuing via Laravel Horizon framework";
    #   after = [ "network.target" "traewelling-data-setup.service" ];
    #   requires = [ "traewelling-data-setup.service" ]
    #     ++ (lib.optional cfg.database.createLocally dbService dbService dbService dbService)
    #     ++ (lib.optional cfg.redis.createLocally redisService);
    #   wantedBy = ["multi-user.target"];
    #   serviceConfig = {
    #     Type = "simple";
    #     ExecStart = "${traewelling-manage}/bin/traewelling-manage horizon";
    #     StateDirectory =
    #       lib.mkIf (cfg.dataDir == "/var/lib/traewelling") "traewelling";
    #     User = user;
    #     Group = group;
    #     Restart = "on-failure";
    #   };
    # };
    systemd.timers.traewelling-cron = {
      description = "Traewelling periodic tasks timer";
      after = ["traewelling-data-setup.service"];
      requires = ["phpfpm-traewelling.service"];
      wantedBy = ["timers.target"];

      timerConfig = {
        OnBootSec = cfg.schedulerInterval;
        OnUnitActiveSec = cfg.schedulerInterval;
      };
    };

    systemd.services.traewelling-cron = {
      description = "Traewelling periodic tasks";
      serviceConfig = {
        ExecStart = "${traewelling-manage}/bin/traewelling-manage schedule:run";
        User = user;
        Group = group;
        StateDirectory =
          lib.mkIf (cfg.dataDir == "/var/lib/traewelling") "traewelling";
      };
    };

    systemd.services.traewelling-data.setup = {
      description =
        "Traewelling setup: migrations, environment file update, cache reload, data changes";
      wantedBy = ["multi-user.target"];
      after = lib.optional cfg.database.createLocally dbService;
      requires = lib.optional cfg.database.createLocally dbService;
      path = with pkgs; [ bash traewelling-manage rsync ];

      serviceConfig = {
        Type = "oneshot";
        User = user;
        Group = group;
        StateDirectory = lib.mkIf (cfg.dataDir == "/var/lib/traewelling") "traewelling";
        LoadCredential = "env-secrets:${cfg.secretFile}";
        UMask = "077";
      };
      
      script = ''
        # Before running any PHP program, cleanup the code cache.
        # It's necessary if you upgrade the application otherwise you might
        # try to import non-existent modules.
        rm -f ${cfg.runtimeDir}/app.php
        rm -rf ${cfg.runtimeDir}/cache/*

        # Concatenate non-secret .env and secret .env
        rm -f ${cfg.dataDir}/.env
        cp --no-preserve=all ${configFile} ${cfg.dataDir}/.env
        echo -e '\n' >> ${cfg.dataDir}/.env
        cat "$CREDENTIALS_DIRECTORY/env-secrets" >> ${cfg.dataDir}/.env

        # Link the static storage (package provided) to the runtime storage
        mkdir -p ${cfg.dataDir}/storage
        rsync -av --no-perms ${traewelling}/storage-static/ ${cfg.dataDir}/storage
        chmod -R +w ${cfg.dataDir}/storage

        chmod g+x ${cfg.dataDir}/storage ${cfg.dataDir}/storage/app
        chmod -R g+rX ${cfg.dataDir}/storage/app/public

        # Link the app.php in the runtime folder.
        # We cannot link the cache folder only because bootstrap folder needs to be writeable.
        ln -sf ${traewelling}/bootstrap-static/app.php ${cfg.runtimeDir}/app.php

        # Perform the first migration.
        [[ ! -f ${cfg.dataDir}/.initial-migration ]] && traewelling-manage migrate --force && touch ${cfg.dataDir}/.initial-migration

        ${lib.optionalString cfg.database.automaticMigrations ''
          # Force migrate the database.
          traewelling-manage migrate --force
        ''}

        traewelling-manage route:cache
        traewelling-manage view:cache
        traewelling-manage config:cache
      '';
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.runtimeDir}/             0700 ${user} ${group} - -"
      "d ${cfg.runtimeDir}/cache        0700 ${user} ${group} - -"
    ];

    users.users."${config.services.nginx.user}".extraGroups = [ cfg.group ];
    services.nginx = lib.mkIf (cfg.nginx != null) {
      enable = true;
      virtualHosts."${cfg.domain}" = lib.mkMerge [
        cfg.nginx
        {
          root = lib.mkForce "${traewelling}/public/";
          locations."/".tryFiles = "$uri $uri/ /index.php?$query_string";
          locations."/favicon.ico".extraConfig = ''
            access_log off; log_not_found off;
          '';
          locations."/robots.txt".extraConfig = ''
            access_log off; log_not_found off;
          '';
          locations."~ \\.php$".extraConfig = ''
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:${config.services.phpfpm.pools.traewelling.socket};
            fastcgi_index index.php;
          '';
          locations."~ /\\.(?!well-known).*".extraConfig = ''
            deny all;
          '';
          extraConfig = ''
            add_header X-Frame-Options "SAMEORIGIN";
            add_header X-XSS-Protection "1; mode=block";
            add_header X-Content-Type-Options "nosniff";
            index index.html index.htm index.php;
            error_page 404 /index.php;
            client_max_body_size ${toString cfg.maxUploadSize};
          '';
        }
      ];
    };
  };
}
