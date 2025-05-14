{ config, pkgs, ... }:
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
      DEFAULT = {
        APP_NAME = "marie's catgit: git with more meow";
      };
      server = {
        PROTOCOL = "http";
        HTTP_PORT = 8085;
        DOMAIN = "git.marie.cologne";
        ROOT_URL = "https://git.marie.cologne";
        STATIC_URL_PREFIX = "/_/static";
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
    };
  };

  services.nginx.virtualHosts."git.marie.cologne" = 
  let
    port = toString config.services.forgejo.settings.server.HTTP_PORT;
  in {
    locations."/_/static/" = {
      alias = "${config.services.forgejo.package.data}/public/";
    };
    locations."/" = {
      proxyPass = "http://localhost:${port}";
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
      proxyPass = "http://localhost:${port}";
      extraConfig = ''
        allow 127.0.0.0/24;
        deny all;
      '';
    };
  };
  services.openssh.extraConfig = ''
    AcceptEnv GIT_PROTOCOL
  '';
}
