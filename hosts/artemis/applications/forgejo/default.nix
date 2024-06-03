{ config, pkgs, ... }:
{
  services.forgejo = {
    enable = true;
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
        PROTOCOL = "fcgi+unix";
        DOMAIN = "git.marie.cologne";
        ROOT_URL = "https://git.marie.cologne";
        STATIC_URL_PREFIX = "/_/static";
      };
      other = {
        SHOW_FOOTER_VERSION = true;
      };
      service.DISABLE_REGISTRATION = true;
      session = {
        COOKIE_SECURE = true;
        PROVIDER = "db";
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
      };
    };
  };

  services.nginx.virtualHosts."git.marie.cologne" = {
    locations."/_/static/" = {
      alias = "${config.services.forgejo.package.data}/public/";
    };
    locations."/" = {
      extraConfig = ''
        client_max_body_size 512M;
        include ${pkgs.nginx}/conf/fastcgi.conf;
        fastcgi_pass unix:/run/forgejo/forgejo.sock;
      '';
    };
    locations."/robots.txt" = {
      return = 
        ''
          200 'User-Agent: *
          Disallow: /'
        '';
    };
    locations."/metrics" = {
      extraConfig = ''
        allow 127.0.0.0/24;
        allow 10.69.0.0/24;
        deny all;
        client_max_body_size 512M;
        include ${pkgs.nginx}/conf/fastcgi.conf;
        fastcgi_pass unix:/run/forgejo/forgejo.sock;
      '';
    };
  };
  services.openssh.extraConfig = ''
    AcceptEnv GIT_PROTOCOL
  '';
}
