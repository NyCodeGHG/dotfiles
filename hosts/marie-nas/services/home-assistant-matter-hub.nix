{
  config,
  pkgs,
  lib,
  ...
}:
{
  systemd.services.home-assistant-matter-hub = {
    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.home-assistant-matter-hub} start";
      DynamicUser = true;
      User = "home-assistant-matter-hub";
      Group = "home-assistant-matter-hub";
      StateDirectory = "home-assistant-matter-hub";
      EnvironmentFile = config.age.secrets.matter-hub-env.path;
    };
    environment = {
      HAMH_HOME_ASSISTANT_URL = "https://hass.marie.cologne";
      HAMH_LOG_LEVEL = "info";
      HAMH_HTTP_PORT = "8482";
      HAMH_STORAGE_LOCATION = "/var/lib/home-assistant-matter-hub";
    };
    wantedBy = [ "multi-user.target" ];
  };
  age.secrets.matter-hub-env.file = ../secrets/matter-bridge-env.age;

  networking.firewall = {
    allowedUDPPorts = [ 5540 ];
    allowedTCPPorts = [ 5540 ];
  };

  services.nginx.virtualHosts."matter-hub.home.marie.cologne" = {
    useACMEHost = "matter-hub.home.marie.cologne";
    locations."/" = {
      proxyPass = "http://127.0.0.1:8482";
      proxyWebsockets = true;
    };
  };

  security.acme.certs."matter-hub.home.marie.cologne" = { };
}
