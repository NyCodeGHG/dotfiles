{
  config,
  pkgs,
  ...
}:
{
  services.forgejo = {
    enable = true;
    package = pkgs.forgejo;
    user = "forgejo";
    group = "forgejo";
    database = {
      type = "postgres";
      createDatabase = true;
      user = "forgejo";
      name = "forgejo";
    };
    lfs.enable = true;
    settings = {
      server = {
        PROTOCOL = "http";
        HTTP_PORT = 8085;
        DOMAIN = "git.marie.cologne";
        ROOT_URL = "https://git.marie.cologne";
        OFFLINE_MODE = false;
      };
      other = {
        SHOW_FOOTER_VERSION = true;
      };
      service = {
        ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
        SHOW_REGISTRATION_BUTTON = false;
        ENABLE_BASIC_AUTHENTICATION = false;
      };
      session = {
        COOKIE_SECURE = true;
        PROVIDER = "db";
        SESSION_LIFE_TIME = 1209600;
      };
      cron.ENABLED = true;
      actions.ENABLED = true;
      repository = {
        DISABLE_STARS = true;
        "upload.ENABLED" = false;
      };
      oauth2_client = {
        ENABLE_AUTO_REGISTRATION = true;
        REGISTER_EMAIL_CONFIRM = false;
        USERNAME = "nickname";
      };
      metrics.ENABLED = true;
      ui = {
        DEFAULT_THEME = "gitdotgay";
        THEMES = "gitdotgay, gitdotgay-light, gitdotgay-dark, forgejo-auto, forgejo-light, forgejo-dark, gitea-auto, gitea-light, gitea-dark, forgejo-auto-deuteranopia-protanopia, forgejo-light-deuteranopia-protanopia, forgejo-dark-deuteranopia-protanopia, forgejo-auto-tritanopia, forgejo-light-tritanopia, forgejo-dark-tritanopia";
      };
    };
  };

  services.nginx.virtualHosts."git.marie.cologne" = {
    locations."/" = {
      proxyPass = "http://unix:${config.services.anubis.instances.forgejo.settings.BIND}";
      extraConfig = ''
        client_max_body_size 512M;
      '';
    };
    locations."/robots.txt" = {
      extraConfig = ''
        return 200 "User-agent: *\nDisallow: /\n";
      '';
    };
    locations."/metrics" = {
      proxyPass = "http://127.0.0.1:${toString config.services.forgejo.settings.server.HTTP_PORT}";
      extraConfig = ''
        allow 127.0.0.0/24;
        deny all;
      '';
    };
  };
  services.openssh.extraConfig = ''
    AcceptEnv GIT_PROTOCOL
  '';

  services.anubis = {
    instances.forgejo = {
      settings = {
        TARGET = "http://127.0.0.1:${toString config.services.forgejo.settings.server.HTTP_PORT}";
        BIND = "/run/anubis/anubis-forgejo/anubis.sock";
        METRICS_BIND = ":9090";
        METRICS_BIND_NETWORK = "tcp";
      };
      policy = {
        useDefaultBotRules = true;
        settings = {
          honeypot = {
            enabled = true;
            implementation = "naive";
            ip_log_file = "/var/log/anubis-forgejo/honeypot.addrs";
          };
        };
        extraBots = [
          {
            import = "(data)/crawlers/tencent-cloud.yaml";
          }
          {
            import = "(data)/clients/docker-client.yaml";
          }
          {
            name = "forgejo-runner";
            path_regex = "^/api/actions/(?:runner\\.v1\\.RunnerService|ping\\.v1\\.PingService)/.*$";
            action = "ALLOW";
          }
          {
            name = "blackbox-exporter";
            action = "ALLOW";
            expression.all = [
              ''userAgent.startsWith("Blackbox Exporter/")''
              ''path == "/"''
            ];
          }
        ];
      };
    };
  };

  systemd.services.anubis-forgejo.serviceConfig = {
    LogsDirectory = "anubis-forgejo";
  };

  environment.etc."alloy/anubis-forgejo.alloy".text = ''
    scrape_local "anubis_forgejo" {
      name = "anubis_forgejo" 
      port = 9090
    } 
    scrape_local "forgejo" {
      name = "forgejo" 
      port = ${toString config.services.forgejo.settings.server.HTTP_PORT}
    } 
  '';

  systemd.tmpfiles.rules =
    let
      cfg = config.services.forgejo;
      gitgaySrc = pkgs.fetchFromGitea {
        domain = "git.gay";
        owner = "gitgay";
        repo = "forgejo";
        rev = "9f4d19af953588a0595f05d59982549475494121";
        hash = "sha256-8wNoFmg2jyDJU3KTtdx/Ji4cHf6CXger1dTUb0AcCPk=";
      };
      gitgayAssets = pkgs.fetchFromGitea {
        domain = "git.gay";
        owner = "gitgay";
        repo = "assets";
        rev = "66519eb5cab2e072fd12a71c013826efb61928ba";
        hash = "sha256-QMwprSD+k0qu3HMCYHlsOdqSA708BdMS2j0bcfoWWAU=";
      };
      customContent = pkgs.runCommand "forgejo-custom-content" { } ''
        mkdir -p $out/{public/assets/css,templates/base}
        cp ${gitgaySrc}/web_src/css/themes/theme-gitdotgay{,-light,-dark}.css $out/public/assets/css
        cp ${./custom-content/head_style.tmpl} $out/templates/base/head_style.tmpl
        cp ${gitgayAssets}/public/assets/font/DMSans/* $out/public/assets/css
      '';
    in
    [
      "d '${cfg.customDir}/public' 0750 ${cfg.user} ${cfg.group} - -"
      "L+ '${cfg.customDir}/public/assets' - - - - ${customContent}/public/assets"
      "L+ '${cfg.customDir}/templates' - - - - ${customContent}/templates"
    ];
}
