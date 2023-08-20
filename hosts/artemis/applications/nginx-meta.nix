{ ... }:
{
  services.nginx.virtualHosts."marie.cologne" = {
    locations."/" = {
      tryFiles = "$uri =404";
    };
  };
}
