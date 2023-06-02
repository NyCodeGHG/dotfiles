{ config, inputs, ... }:
{
  imports = [
    "${inputs.self}/modules/coder.nix"
  ];
  uwumarie.services.coder = {
    enable = true;
    accessUrl = "https://coder.marie.cologne";
    wildcardUrl = "*.coder.marie.cologne";
    nginx = {
      enable = true;
      extraConfig = {
        forceSSL = true;
        http2 = true;
        useACMEHost = "coder.marie.cologne";
      };
    };
    extraEnvironment = {
      CODER_OIDC_ALLOW_SIGNUPS = "true";
      CODER_OIDC_SIGN_IN_TEXT = "Sign in with Authentik";
      CODER_OIDC_ICON_URL = "https://goauthentik.io/img/icon_top_brand.svg";
      CODER_DISABLE_PASSWORD_AUTH = "true";
      CODER_OIDC_ISSUER_URL = "https://sso.nycode.dev/application/o/coder/";
      CODER_OIDC_CLIENT_ID = "aPUdOxV1jOHqCUyI3EV3QP1nWlv23qp3QvSPYVfY";
    };
    environmentFiles = [
      config.age.secrets.coder-oauth.path
    ];
  };
  age.secrets.coder-oauth.file = "${inputs.self}/secrets/coder-oauth.age";
  security.acme.certs."coder.marie.cologne" = {
    domain = "coder.marie.cologne";
    extraDomainNames = [
      "*.coder.marie.cologne"
    ];
  };
}
