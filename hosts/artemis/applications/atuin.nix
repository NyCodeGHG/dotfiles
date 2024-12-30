{ config, ... }:
{
  services.atuin = {
    enable = true;
    openRegistration = false;
  };

  services.nginx.virtualHosts."atuin.marie.cologne" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.atuin.port}";
      proxyWebsockets = true;
    };
  };
}
