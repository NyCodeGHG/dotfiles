{ pkgs, config, ... }:
{
  systemd.services.transmission = {
    after = [ "setup-netns-vpn.service" ];
    wants = [ "setup-netns-vpn.service" ];
    bindsTo = [ "netns@vpn.service" ];
    serviceConfig = {
      NetworkNamespacePath = "/var/run/netns/vpn";
      Type = "notify";
    };
  };

  systemd.services.transmission-proxy = {
    after = [ "transmission.service" ];
    requires = [ "transmission.service" ];
    bindsTo = [ "netns@vpn.service" ];
    serviceConfig = {
      Type = "notify";
      NetworkNamespacePath = "/var/run/netns/vpn";
      ExecStart = "${config.systemd.package}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:9091";
    };
  };

  systemd.sockets.transmission-proxy = {
    listenStreams = [ "9091" ];
    wantedBy = [ "sockets.target" ];
  };

  services.nginx.virtualHosts."bt.marie.cologne".locations."/" = {
    proxyPass = "http://127.0.0.1:9091";
    proxyWebsockets = true;
  };

  age.secrets.transmission = {
    file = ../secrets/transmission.age;
    owner = "transmission";
  };

  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;

    group = "media";
    credentialsFile = config.age.secrets.transmission.path;

    settings = {
      incomplete-dir-enabled = false;

      rpc-authentication-required = true;
      rpc-username = "transmission";

      rpc-host-whitelist-enabled = false;
      rpc-whitelist-enabled = false;
    };
  };
}
