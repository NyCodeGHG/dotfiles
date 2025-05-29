{ config, ... }:
{
  virtualisation.oci-containers.containers.matter-hub = {
    image = "ghcr.io/t0bst4r/home-assistant-matter-hub:3.0.0-alpha.84";
    extraOptions = [
      "--network=host"
    ];
    environment = {
      HAMH_HOME_ASSISTANT_URL = "https://hass.marie.cologne";
      HAMH_LOG_LEVEL = "info";
      HAMH_HTTP_PORT = "8482";
    };
    environmentFiles = [ config.age.secrets.matter-hub-env.path ];
    volumes = [
      "/var/lib/home-assistant-matter-hub:/data"
    ];
  };
  age.secrets.matter-hub-env.file = ../secrets/matter-bridge-env.age;

  networking.firewall = {
    allowedUDPPorts = [ 5540 ];
    allowedTCPPorts = [ 5540 ];
  };

  systemd.tmpfiles.settings."matter-hub" = {
    "/var/lib/home-assistant-matter-hub".d = {
      user = "root";
      group = "root";
      mode = "0700";
    };
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
