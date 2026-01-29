{
  pkgs,
  config,
  inputs,
  ...
}:
{
  systemd.services.transmission = {
    after = [ "netns@vpn.target" ];
    bindsTo = [ "netns@vpn.target" ];
    serviceConfig = {
      NetworkNamespacePath = "/var/run/netns/vpn";
      Type = "notify";
      BindReadOnlyPaths = "${config.vpn.dns.resolvconf}:/etc/resolv.conf:norbind";
      InaccessiblePaths = "/run/nscd/socket";
    };
  };

  systemd.services.transmission-proxy = {
    after = [
      "transmission.service"
      "netns@vpn.target"
    ];
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

  systemd.services.transmission-nginx-credentials = {
    before = [ "nginx.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "rm /run/nginx-transmission-auth.conf";
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadOnlyPaths = "/run/agenix";
      ReadWritePaths = "/run";
      CapabilityBoundingSet = [
        "CAP_CHOWN"
        "CAP_FOWNER"
        "CAP_DAC_OVERRIDE"
      ];
      NoNewPrivileges = true;
      RestrictAddressFamilies = "none";
      ProtectKernelTunables = true;
      ProtectControlGroups = true;
      PrivateDevices = true;
      ProtectClock = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      SystemCallArchitectures = "native";
      MemoryDenyWriteExecute = true;
      RestrictNamespaces = true;
      RestrictSUIDSGID = true;
      ProtectHostname = true;
      LockPersonality = true;
      RestrictRealtime = true;
      ProtectProc = "invisible";
      ProcSubset = "pid";
      PrivateNetwork = true;
      PrivateTmp = true;
      SystemCallFilter = [ "@system-service" ];
      UMask = "177";
    };
    path = with pkgs; [
      jq
      coreutils
    ];
    script = ''
      PASSWORD=$(jq -r '."rpc-password"' /run/agenix/transmission)
      BASE64=$(echo -n "transmission:$PASSWORD" | base64 | tr -d '\n')
      TARGET_FILE="/run/nginx-transmission-auth.conf"

      touch "$TARGET_FILE"
      chmod 600 "$TARGET_FILE"
      chown nginx:nginx "$TARGET_FILE"

      echo "proxy_set_header Authorization \"Basic $BASE64\";" > "$TARGET_FILE"
    '';
  };

  services.nginx.virtualHosts."bt.marie.cologne".locations."/" = {
    proxyPass = "http://127.0.0.1:9091";
    proxyWebsockets = true;
    extraConfig = ''
      include /run/nginx-transmission-auth.conf;
    '';
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

      idle-seeding-limit-enabled = false;
      ratio-limit-enabled = false;

      speed-limit-up = 2500;
      speed-limit-up-enabled = true;

      speed-limit-down = 7500;
      speed-limit-down-enabled = true;

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
