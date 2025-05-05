{ config, inputs, ... }:
{
  virtualisation.podman.enable = true;
  uwumarie.services.authentik = {
    enable = true;
    environmentFiles = [
      config.age.secrets.authentik-secrets.path
    ];
    ldap = {
      enable = false;
    };
    nginx = {
      enable = true;
      domain = "sso.nycode.dev";
    };
  };
  age.secrets.authentik-secrets.file = "${inputs.self}/secrets/authentik-secrets.age";

  services.nginx.commonHttpConfig = ''
    proxy_cache_path /var/cache/nginx/ keys_zone=cache:10m;
  '';

  services.nginx.virtualHosts."sso.nycode.dev" = {
    extraConfig = ''
      error_page 401 /sso_unavailable.html;

      location = /sso_unavailable.html {
        root ${./nginx};
        internal;
      }
    '';

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

    locations."/" = {
      extraConfig = ''
        satisfy any;
        allow 2a03:4000:5f:f5b::;
        allow 127.0.0.1;
        allow 2a05:d014:386:202::/64;
        allow 2a00:e67:5c6::/48;
        allow 185.104.142.74;
        deny all;
      '';
    };
  };
  services.nginx.tailscaleAuth = {
    enable = true;
    virtualHosts = [ "sso.nycode.dev" ];
  };
}
