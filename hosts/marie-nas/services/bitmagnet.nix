{ pkgs, config, ... }:
{
  services.bitmagnet = {
    enable = true;
    settings = {
      dht_crawler.scaling_factor = 4;
      classifier.flags.delete_content_types = [
        "xxx"
        "game"
        "software"
        "comic"
        "ebook"
      ];
    };
  };

  systemd.services.bitmagnet = {
    after = [ "netns@vpn.target" ];
    bindsTo = [ "netns@vpn.target" ];
    serviceConfig = {
      NetworkNamespacePath = "/var/run/netns/vpn";
      BindReadOnlyPaths = "${config.vpn.dns.resolvconf}:/etc/resolv.conf:norbind";
    };
  };

  systemd.services.bitmagnet-proxy = {
    after = [ "bitmagnet.service" ];
    requires = [ "bitmagnet.service" ];
    bindsTo = [ "netns@vpn.target" ];
    serviceConfig = {
      Type = "notify";
      NetworkNamespacePath = "/var/run/netns/vpn";
      ExecStart = "${config.systemd.package}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:3333";
    };
  };

  systemd.sockets.bitmagnet-proxy = {
    listenStreams = [ "3333" ];
    wantedBy = [ "sockets.target" ];
  };

  services.nginx.virtualHosts."bitmagnet.marie.cologne".locations."/" = {
    proxyPass = "http://127.0.0.1:3333";
    proxyWebsockets = true;
  };
}
