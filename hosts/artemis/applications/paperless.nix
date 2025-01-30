{ config, inputs, ... }:
{
  services.paperless = {
    enable = true;
    settings = {
      PAPERLESS_URL = "https://paperless.marie.cologne";
      PAPERLESS_TRUSTED_PROXIES = "127.0.0.1";
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_TIKA_ENABLED = true;
      PAPERLESS_TIKA_ENDPOINT = "http://127.0.0.1:${toString config.services.tika.port}";
      PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://127.0.0.1:${toString config.services.gotenberg.port}";
      PAPERLESS_ENABLE_COMPRESSION = false;
      PAPERLESS_USE_X_FORWARD_HOST = true;
      PAPERLESS_USE_X_FORWARD_PORT = true;
      PAPERLESS_DBHOST = "/run/postgresql";
    };
  };
  services.postgresql = {
    enable = true;
    ensureDatabases = [
      "paperless"
    ];
    ensureUsers = [
      {
        name = "paperless";
        ensureDBOwnership = true;
      }
    ];
  };
  systemd.services =
    let
      path = config.age.secrets.paperless-env.path;
    in
    {
      paperless-scheduler.serviceConfig.EnvironmentFile = path;
      paperless-task-queue.serviceConfig.EnvironmentFile = path;
      paperless-consumer.serviceConfig.EnvironmentFile = path;
      paperless-web.serviceConfig.EnvironmentFile = path;
    };
  age.secrets.paperless-env.file = "${inputs.self}/secrets/paperless-env.age";

  services.nginx.virtualHosts."paperless.marie.cologne" = {
    extraConfig = ''
      client_max_body_size 50m;
    '';
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.paperless.port}";
      proxyWebsockets = true;
    };
  };

  services.nginx.tailscaleAuth = {
    enable = true;
    virtualHosts = [ "paperless.marie.cologne" ];
  };

  services.tika.enable = true;
  services.gotenberg = {
    enable = true;
    chromium.disableJavascript = true;
    port = 26840;
  };
}
