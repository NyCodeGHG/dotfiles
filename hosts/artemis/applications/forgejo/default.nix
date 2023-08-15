{ config, pkgs, ... }:
{
  services.gitea = {
    enable = true;
    user = "forgejo";
    group = "forgejo";
    package = pkgs.forgejo;
    database = {
      type = "postgres";
      createDatabase = true;
      user = "forgejo";
      name = "forgejo";
    };
    lfs.enable = true;
    appName = "marie's catgit: git with more meow";
    settings ={
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
    };
  };
  users.users = 
  let
    cfg = config.services.gitea;
  in
  {
    forgejo = {
      description = "Forgejo Service";
      home = cfg.stateDir;
      useDefaultShell = true;
      group = cfg.group;
      isSystemUser = true;
    };
  };

  users.groups = {
    forgejo = {};
  };

  uwumarie.reverse-proxy.services."git.marie.cologne" = {
    locations."/_/static/assets/" = {
      alias = "${pkgs.forgejo.data}/public/";
    };
    locations."/" = {
      extraConfig = ''
        client_max_body_size 512M;
        include ${pkgs.nginx}/conf/fastcgi.conf;
        fastcgi_pass unix:/run/gitea/gitea.sock;
      '';
    };
    locations."/metrics" = {
      extraConfig = ''
        allow 127.0.0.0/24;
        allow 10.69.0.0/24;
        deny all;
        client_max_body_size 512M;
        include ${pkgs.nginx}/conf/fastcgi.conf;
        fastcgi_pass unix:/run/gitea/gitea.sock;
      '';
    };
  };
}