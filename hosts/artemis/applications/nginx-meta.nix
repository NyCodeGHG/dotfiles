{ ... }:
{
  services.nginx.virtualHosts."marie.cologne" = {
    locations."/" = {
      tryFiles = "$uri =404";
      root = "/var/lib/www";
    };
  };
}
