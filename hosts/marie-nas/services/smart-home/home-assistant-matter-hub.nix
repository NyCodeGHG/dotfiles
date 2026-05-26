{
  config,
  ...
}:
{
  services.home-assistant-matter-hub = {
    enable = true;
    openFirewall = true;
    accessTokenFile = config.age.secrets.matter-hub-token.path;
    settings = {
      homeAssistantUrl = "https://hass.marie.cologne";
    };
  };
  age.secrets.matter-hub-token.file = ../../secrets/matter-hub-token.age;

  services.nginx.virtualHosts."matter-hub.home.marie.cologne" = {
    useACMEHost = "matter-hub.home.marie.cologne";
    locations."/" = {
      proxyPass = "http://127.0.0.1:8482";
      proxyWebsockets = true;
    };
  };

  security.acme.certs."matter-hub.home.marie.cologne" = { };
}
