{ lib, config, inputs, ... }:

let
  port = "8001";
in
{
  services.miniflux = {
    enable = true;
    config = {
      OAUTH2_PROVIDER = "oidc";
      OAUTH2_REDIRECT_URL = "https://miniflux.nycode.dev/oauth2/oidc/callback";
      OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://sso.nycode.dev/application/o/miniflux/";
      OAUTH2_USER_CREATION = "1";
      PORT = port;
      BASE_URL = "https://miniflux.marie.cologne";
      CREATE_ADMIN = lib.mkForce "0";
    };
    adminCredentialsFile = config.age.secrets.miniflux-credentials.path;
  };
  age.secrets.miniflux-credentials.file = "${inputs.self}/secrets/miniflux-credentials.age";

  services.nginx.virtualHosts = {
    "miniflux.marie.cologne" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${port}";
        proxyWebsockets = true;
      };
    };
    "miniflux.nycode.dev" = {
      globalRedirect = "miniflux.marie.cologne";
    };
  };
}
