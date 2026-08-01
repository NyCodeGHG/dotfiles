{ config, ... }:
{
  services.sabnzbd = {
    enable = true;
    allowConfigWrite = true;
    group = "media";
    configFile = null;
    settings = {
      misc = {
        host_whitelist = "sab.marie.cologne";
        download_dir = "/srv/shares/media/Downloads/sabnzbd-download";
        complete_dir = "/srv/shares/media/Downloads/sabnzbd-complete";
        permissions = 750;
      };
    };
  };

  services.nginx.virtualHosts."sab.marie.cologne" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.sabnzbd.settings.misc.port}";
      proxyWebsockets = true;
    };
    locations."/api" = {
      # extra entry to bypass oauth2-proxy
      proxyPass = "http://127.0.0.1:${toString config.services.sabnzbd.settings.misc.port}";
      proxyWebsockets = true;
      extraConfig = ''
        auth_request off;
      '';
    };
  };
}
