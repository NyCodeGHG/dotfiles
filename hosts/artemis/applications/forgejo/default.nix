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
      server = {
        APP_NAME = "marie's catgit: git with more meow";
        PROTOCOL = "fcgi+unix";
        DOMAIN = "git.marie.cologne";
        ROOT_URL = "https://git.marie.cologne";
        STATIC_URL_PREFIX = "/_/static";
      };
      other = {
        SHOW_FOOTER_BRANDING = false;
        SHOW_FOOTER_VERSION = true;
      };
      service.DISABLE_REGISTRATION = true;
      session = {
        COOKIE_SECURE = true;
        PROVIDER = "db";
      };
      cron.ENABLED = true;
      "cron.update_checker".ENABLED = true;
      metrics.ENABLED = true;
      actions.ENABLED = true;
      oauth2_client = {
        ENABLE_AUTO_REGISTRATION = true;
        REGISTER_EMAIL_CONFIRM = false;
      };
    };
    package = pkgs.forgejo.override {
      buildGoModule = args: pkgs.buildGoModule (args // rec {
        version = "1.21.1-0";
        src = pkgs.fetchFromGitea {
          domain = "codeberg.org";
          owner = "forgejo";
          repo = "forgejo";
          rev = "v${version}";
          hash = "sha256-e7Y1YBJq3PwYl7hf5KUa/CSI4ihbpN/TjWwltjNwXRM=";
        };
        vendorHash = "sha256-+/wOEF44dSqy7ZThZyd66xyI3wVnFwZbsAd4ujyVku8=";
      });
    };
  };

  services.nginx.virtualHosts."git.marie.cologne" = {
    locations."/_/static/assets/" = {
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
