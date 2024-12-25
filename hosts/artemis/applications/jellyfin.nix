{ ... }:
{
  services.jellyfin.enable = true;
  services.nginx.virtualHosts."jellyfin.marie.cologne".locations."/" = {
    proxyPass = "http://127.0.0.1:8096";
    proxyWebsockets = true;
  };
  users.users.marie.extraGroups = [ "jellyfin" ];

  services.nginx.tailscaleAuth = {
    enable = true;
    virtualHosts = [ "jellyfin.marie.cologne" ];
  };
}
