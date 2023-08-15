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
        DOMAIN = "git2.marie.cologne";
        ROOT_URL = "https://git2.marie.cologne";
        STATIC_URL_PREFIX = "/_/static";
      };
      service.DISABLE_REGISTRATION = true;
      session.COOKIE_SECURE = true;
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

  uwumarie.reverse-proxy.services."git2.marie.cologne" = {
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
  };
}