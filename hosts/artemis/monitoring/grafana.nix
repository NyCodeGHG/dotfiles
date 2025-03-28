{ config, inputs, pkgs, ... }:
let
  port = 3000;
in
{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = port;
        domain = "grafana.marie.cologne";
        root_url = "https://grafana.marie.cologne";
      };
      security = {
        disable_initial_admin_creation = true;
        cookie_secure = true;
      };
      auth = {
        signout_redirect_url = "https://sso.nycode.dev/if/session-end/grafana/";
        disable_login_form = true;
      };
      "auth.generic_oauth" = {
        name = "Authentik";
        icon = "signin";
        enabled = true;
        allow_sign_up = true;
        auto_login = false;
        client_id = "faec063568d698926dbb10fb4d3fcc59761c5a7d";
        client_secret = "$__file{${config.age.secrets.grafana-oauth-client-secret.path}}";
        scopes = "openid profile email";
        auth_url = "https://sso.nycode.dev/application/o/authorize/";
        token_url = "https://sso.nycode.dev/application/o/token/";
        api_url = "https://sso.nycode.dev/application/o/userinfo/";
        use_pkce = true;
        allow_assign_grafana_admin = true;
        role_attribute_path = "contains(groups[*], 'grafana-server-admin') && 'GrafanaAdmin' || contains(groups[*], 'grafana-admin') && 'Admin' || contains(groups[*], 'grafana-edit') && 'Editor' || 'Viewer'";
        login_attribute_path = "preferred_username";
        name_attribute_path = "nickname";
        id_token_attribute_name = "sub";
      };
      database = {
        type = "postgres";
        user = "grafana";
        host = "/run/postgresql";
      };
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus artemis";
          type = "prometheus";
          access = "proxy";
          url = "http://127.0.0.1:${toString config.services.prometheus.port}";
        }
      ];
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "grafana" ];
    ensureUsers = [{
      name = "grafana";
      ensureDBOwnership = true;
    }];
  };

  age.secrets.grafana-oauth-client-secret = {
    file = "${inputs.self}/secrets/grafana-oauth-client-secret.age";
    owner = "grafana";
    group = "grafana";
  };

  services.nginx.virtualHosts = {
    "grafana.marie.cologne" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${builtins.toString port}";
        proxyWebsockets = true;
      };
    };
    "grafana.nycode.dev" = {
      globalRedirect = "grafana.marie.cologne";
    };
  };
}
