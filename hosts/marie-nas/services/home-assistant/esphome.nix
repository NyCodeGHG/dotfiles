{ ... }:
{
  virtualisation.oci-containers.containers.esphome = {
    image = "ghcr.io/esphome/esphome:2026.4.3";
    volumes = [
      "/var/lib/esphome:/config"
      "/etc/localtime:/etc/localtime:ro"
    ];
    privileged = true;
    extraOptions = [ "--network=host" ];
  };
  services.nginx.virtualHosts."esphome.home.marie.cologne" = {
    useACMEHost = "esphome.home.marie.cologne";
    locations."/" = {
      proxyPass = "http://127.0.0.1:6052";
      proxyWebsockets = true;
    };
  };

  security.acme.certs."esphome.home.marie.cologne" = { };
}
