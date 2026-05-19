{ pkgs, lib, ... }:
{
  systemd.services.proxyt = {
    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${lib.getExe pkgs.proxyt} serve --http-only --domain tsp.marie.cologne --port 5678 --bind [::1]";
    };

    after = [ "network.target" ];
    wants = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
  };

  services.nginx.virtualHosts = {
    "tsp.marie.cologne" = {
      locations."/" = {
        proxyPass = "http://[::1]:5678";
        extraConfig = ''
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $connection_upgrade;
          proxy_buffering off;
        '';
      };
    };
  };
}
