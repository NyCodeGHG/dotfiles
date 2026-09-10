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
          { import = "${../anubis/tencent.yaml}"; }
          { import = "${../anubis/huawei.yaml}"; }
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
}
