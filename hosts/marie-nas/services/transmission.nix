{ pkgs, config, inputs, ... }:
{
  systemd.services.transmission = {
    after = [ "netns@vpn.target" ];
    bindsTo = [ "netns@vpn.target" ];
    serviceConfig = {
      NetworkNamespacePath = "/var/run/netns/vpn";
      Type = "notify";
      BindReadOnlyPaths = "${config.vpn.dns.resolvconf}:/etc/resolv.conf:norbind";
    };
  };

  systemd.services.transmission-proxy = {
    after = [ "transmission.service" "netns@vpn.target" ];
    requires = [ "transmission.service" ];
    bindsTo = [ "netns@vpn.target" ];
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

      default-trackers = builtins.readFile "${inputs.trackerlist}/trackers_all.txt";

      port-forwarding-enabled = false;

      download-dir = "/srv/shares/media/Downloads";

      speed-limit-up = "2500";
      speed-limit-up-enabled = true;

      idle-seeding-limit = "30";
      idle-seeding-limit-enabled = true;

      ratio-limit = "1.5";
      ratio-limit-enabled = true;

      preallocation = false;
    };
  };

  systemd.tmpfiles.settings.transmission = {
    "/srv/shares/media/Downloads".d = {
      group = "media";
      user = "transmission";
      mode = "2770";
    };
  };
}
