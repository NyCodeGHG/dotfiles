{ config, ... }:
{
  services.redis.servers.oauth2-proxy = {
    enable = true;
    user = "oauth2-proxy";
  };

  services.oauth2-proxy = {
    enable = true;

    oidcIssuerUrl = "https://idm.marie.cologne/oauth2/openid/marie-nas-oauth2-proxy";
    clientID = "marie-nas-oauth2-proxy";

    provider = "oidc";
    keyFile = config.age.secrets.oauth2-proxy.path;

    cookie.domain = ".marie.cologne";
    email.domains = [ "*" ];

    extraConfig = {
      code-challenge-method = "S256";
      whitelist-domain = "*.marie.cologne";
      reverse-proxy = true;
      scope = "openid email profile groups";
      session-store-type = "redis";
      redis-connection-url = "unix:/run/redis-oauth2-proxy/redis.sock";
    };

    nginx = {
      domain = "auth.marie-nas.marie.cologne";
      virtualHosts = {
        "bt.marie.cologne".allowed_groups = [ "pirates@idm.marie.cologne" ];
        "prowlarr.marie.cologne".allowed_groups = [ "pirates@idm.marie.cologne" ];
        "sonarr.marie.cologne".allowed_groups = [ "pirates@idm.marie.cologne" ];
        "bitmagnet.marie.cologne".allowed_groups = [ "pirates@idm.marie.cologne" ];
      };
    };
  };

  age.secrets.oauth2-proxy = {
    file = ../secrets/oauth2-proxy.age;
    owner = "oauth2-proxy";
  };
}
