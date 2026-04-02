{
  config,
  ...
}:
{
  virtualisation.oci-containers.containers.home-assistant-matter-hub = {
    image = "ghcr.io/riddix/home-assistant-matter-hub:2.0.36";
    environment = {
      HAMH_HOME_ASSISTANT_URL = "https://hass.marie.cologne";
      HAMH_LOG_LEVEL = "info";
      HAMH_HTTP_PORT = "8482";
      HAMH_STORAGE_LOCATION = "/var/lib/home-assistant-matter-hub";
    };
    volumes = [
      "/var/lib/home-assistant-matter-hub:/var/lib/home-assistant-matter-hub"
    ];
    environmentFiles = [
      config.age.secrets.matter-hub-env.path
    ];
    extraOptions = [ "--network=host" ];
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
