{ ... }:
{
  services.nginx.virtualHosts."marie.cologne" = {
    locations."/" = {
      tryFiles = "$uri =404";
      root = "/var/lib/www";
      extraConfig = ''
        add_header 'Content-Security-Policy' 'upgrade-insecure-requests';
      '';
    };
  };
}
