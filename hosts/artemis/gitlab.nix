{ config, ... }:
let
  secret = path: {
    file = path;
    owner = "gitlab";
    group = "gitlab";
  };
in
{
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
        allow_single_sign_on = [ ];
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
  age.secrets.gitlab-root-password = secret ../../secrets/gitlab-root-password.age;
  age.secrets.gitlab-secret = secret ../../secrets/gitlab-secret.age;
  age.secrets.gitlab-otp-secret = secret ../../secrets/gitlab-otp-secret.age;
  age.secrets.gitlab-jws-key = secret ../../secrets/gitlab-jws-key.age;
  age.secrets.gitlab-db-secret = secret ../../secrets/gitlab-db-secret.age;
  age.secrets.gitlab-github-client-secret = secret ../../secrets/gitlab-github-client-secret.age;

  services.nginx.virtualHosts."git.marie.cologne" = {
    locations."/" = {
      proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
      proxyWebsockets = true;
    };
    forceSSL = true;
    useACMEHost = "marie.cologne";
    http2 = true;
  };
}
