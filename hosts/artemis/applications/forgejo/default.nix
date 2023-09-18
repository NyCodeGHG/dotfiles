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
    appName = "marie's catgit: git with more meow";
    settings = {
      server = {
        PROTOCOL = "fcgi+unix";
        DOMAIN = "git.marie.cologne";
        ROOT_URL = "https://git.marie.cologne";
        STATIC_URL_PREFIX = "/_/static";
      };
      service.DISABLE_REGISTRATION = true;
      session = {
        COOKIE_SECURE = true;
        PROVIDER = "db";
      };
      cron.ENABLED = true;
      metrics.ENABLED = true;
      federation.ENABLED = true;
      actions.ENABLED = true;
      oauth2_client = {
        ENABLE_AUTO_REGISTRATION = true;
        REGISTER_EMAIL_CONFIRM = false;
      };
    };
  };

  services.nginx.virtualHosts."git.marie.cologne" = {
    locations."/_/static/assets/" = {
      alias = "${config.services.forgejo.package}/public/";
    };
    locations."/" = {
      extraConfig = ''
        client_max_body_size 512M;
        include ${pkgs.nginx}/conf/fastcgi.conf;
        fastcgi_pass unix:/run/forgejo/forgejo.sock;
      '';
    };
    locations."/robots.txt" = {
      return = ''200 'User-Agent: *
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
