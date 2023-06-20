{ config, inputs, ... }:
let
  secret = path: {
    file = path;
    owner = "gitlab";
    group = "gitlab";
  };
in
{
  imports = [
    "${inputs.self}/modules/reverse-proxy.nix"
    ./backup.nix
  ];

  services.gitlab = {
    enable = true;
    https = true;
    host = "git.marie.cologne";
    port = 443;
    initialRootEmail = "tabmeier12@gmail.com";
    initialRootPasswordFile = config.age.secrets.gitlab-root-password.path;
    secrets = {
      secretFile = config.age.secrets.gitlab-secret.path;
      otpFile = config.age.secrets.gitlab-otp-secret.path;
      jwsFile = config.age.secrets.gitlab-jws-key.path;
      dbFile = config.age.secrets.gitlab-db-secret.path;
    };
    extraConfig = {
      omniauth = {
        enabled = true;
        allow_single_sign_on = [ "saml" ];
        sync_email_from_provider = "saml";
        sync_profile_from_provider = [ "saml" ];
        sync_profile_attributes = [ "email" ];
        block_auto_created_users = false;
        auto_link_saml_user = true;
        providers = [
          {
            name = "github";
            app_id = "5aa05c735820b136baaf";
            app_secret = {
              _secret = config.age.secrets.gitlab-github-client-secret.path;
            };
            args = {
              scope = "user:email";
            };
          }
          {
            name = "saml";
            label = "Authentik";
            args = {
              assertion_consumer_service_url = "https://git.marie.cologne/users/auth/saml/callback";
              idp_cert_fingerprint = "5b:47:53:84:13:41:33:62:17:d1:08:bd:d2:5e:c1:2a:7c:bd:e5:6d";
              idp_sso_target_url = "https://sso.nycode.dev/application/saml/gitlab/sso/binding/redirect/";
              issuer = "https://git.marie.cologne";
              name_identifier_format = "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent";
              attribute_statements = {
                email = [ "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress" ];
                first_name = [ "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name" ];
                nickname = [ "http://schemas.goauthentik.io/2021/02/saml/username" ];
              };
            };
          }
        ];
      };
      default_projects_features = {
        issues = true;
        merge_requests = true;
        wiki = false;
        snippets = false;
        builds = false;
      };
    };
  };
  age.secrets.gitlab-root-password = secret "${inputs.self}/secrets/gitlab-root-password.age";
  age.secrets.gitlab-secret = secret "${inputs.self}/secrets/gitlab-secret.age";
  age.secrets.gitlab-otp-secret = secret "${inputs.self}/secrets/gitlab-otp-secret.age";
  age.secrets.gitlab-jws-key = secret "${inputs.self}/secrets/gitlab-jws-key.age";
  age.secrets.gitlab-db-secret = secret "${inputs.self}/secrets/gitlab-db-secret.age";
  age.secrets.gitlab-github-client-secret = secret "${inputs.self}/secrets/gitlab-github-client-secret.age";

  uwumarie.reverse-proxy.services."git.marie.cologne" = {
    locations."/" = {
      proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
      proxyWebsockets = true;
    };
  };
}
