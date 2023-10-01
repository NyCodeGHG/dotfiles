{ config, self, ... }:
let
  tikaPort = "33001";
  gotenbergPort = "33002";
in
{
  services.paperless = {
    enable = true;
    extraConfig = {
      PAPERLESS_URL = "https://paperless.marie.cologne";
      PAPERLESS_TRUSTED_PROXIES = "127.0.0.1";
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_TIKA_ENABLED = true;
      PAPERLESS_TIKA_ENDPOINT = "http://10.69.0.1:${tikaPort}";
      PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://127.0.0.1:${gotenbergPort}";
      PAPERLESS_ENABLE_COMPRESSION = false;
      PAPERLESS_USE_X_FORWARD_HOST = true;
      PAPERLESS_USE_X_FORWARD_PORT = true;
    };
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
  age.secrets.paperless-env.file = "${self}/secrets/paperless-env.age";

  virtualisation.oci-containers.containers.gotenberg = {
    user = "gotenberg:gotenberg";
    image = "docker.io/gotenberg/gotenberg:7.9.2";
    cmd = [ "gotenberg" "--chromium-disable-javascript=true" "--chromium-allow-list=file:///tmp/.*" ];
    ports = [
      "127.0.0.1:${gotenbergPort}:3000"
    ];
  };

  services.nginx.virtualHosts."paperless.marie.cologne" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.paperless.port}";
      proxyWebsockets = true;
    };
  };
}
