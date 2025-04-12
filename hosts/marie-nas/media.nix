{ pkgs, ... }:
{
  services.jellyfin = {
    enable = true;
    group = "media";
    openFirewall = true;
  };
  services.nginx.virtualHosts."jellyfin.marie.cologne".locations."/" = {
    proxyPass = "http://127.0.0.1:8096";
    proxyWebsockets = true;
  };
  # thanks, jade
  systemd.tmpfiles.rules = [
    "d /var/lib/jellyfin/plugins 755 jellyfin media - -"
    "C+ /var/lib/jellyfin/plugins/sso 755 jellyfin media - ${pkgs.jellyfin-plugin-sso}"
    "z /var/lib/jellyfin/plugins/sso/meta.json 644 jellyfin media - -"
  ];
}
