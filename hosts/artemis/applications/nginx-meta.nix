{ ... }:
{
  services.nginx.virtualHosts = {
    "marie.cologne" = {
      locations."/" = {
        root = "${../website}";
        index = "index.html";
        tryFiles = "$uri $uri/index.html @fallback";
        extraConfig = ''
          add_header 'Content-Security-Policy' 'upgrade-insecure-requests';
        '';
      };
      locations."@fallback" = {
        root = "/var/lib/www";
        tryFiles = "$uri =404";
        extraConfig = ''
          add_header 'Content-Security-Policy' 'upgrade-insecure-requests';
        '';
      };
    };
    "marie.dn42" = {
      locations."/" = {
        root = "${../website}";
        index = "index.html";
        tryFiles = "$uri $uri/index.html @fallback";
        extraConfig = ''
          add_header 'Content-Security-Policy' 'upgrade-insecure-requests';
        '';
      };
      locations."@fallback" = {
        root = "/var/lib/www";
        tryFiles = "$uri =404";
        extraConfig = ''
          add_header 'Content-Security-Policy' 'upgrade-insecure-requests';
        '';
      };
    };
  };
}
