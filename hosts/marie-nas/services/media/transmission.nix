{
  pkgs,
  config,
  ...
}:
let
  transmissionSettingsDir = "${config.services.transmission.home}/.config/transmission-daemon";
in
{
  systemd.services.transmission = {
    after = [ "netns@vpn.target" ];
    bindsTo = [ "netns@vpn.target" ];
    serviceConfig = {
      NetworkNamespacePath = "/var/run/netns/vpn";
      BindReadOnlyPaths = "${config.vpn.dns.resolvconf}:/etc/resolv.conf:norbind";
      InaccessiblePaths = "/run/nscd/socket";
    };
  };

  systemd.services.transmission-proxy = {
    after = [
      "transmission.service"
      "netns@vpn.target"
    ];
    partOf = [ "netns@vpn.target" ];
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
    file = ../../secrets/transmission.age;
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

  users.groups.trackerslist = { };
  users.users.trackerslist = {
    isSystemUser = true;
    group = "trackerslist";
  };

  systemd.services.trackerslist-update = {
    onSuccess = [ "transmission-load-default-trackers.service" ];
    enableStrictShellChecks = true;
    serviceConfig = {
      Type = "oneshot";
      User = "trackerslist";
      Group = "trackerslist";

      CacheDirectory = "trackerslist";
      CacheDirectoryMode = "0755";
      WorkingDirectory = "%C/trackerslist";
      UMask = "0022";
      TimeoutStartSec = "10min";

      AmbientCapabilities = "";
      CapabilityBoundingSet = "";
      DevicePolicy = "closed";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      PrivateDevices = true;
      PrivateTmp = true;
      PrivateUsers = true;
      ProcSubset = "pid";
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "strict";
      RemoveIPC = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SocketBindDeny = "any";
      SystemCallArchitectures = "native";
      SystemCallFilter = [ "@system-service" ];
      TasksMax = 16;
    };
    path = [
      pkgs.curl
    ];
    script = ''
      rm -f trackers_all.txt.tmp

      curl \
        --fail \
        --silent \
        --show-error \
        --connect-timeout 10 \
        --max-time 60 \
        --retry 5 \
        --retry-max-time 300 \
        --remove-on-error \
        --output trackers_all.txt.tmp \
        --etag-compare trackers_all.txt.etag \
        --etag-save trackers_all.txt.etag \
        "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt"

      if [[ -s trackers_all.txt.tmp ]]; then
        mv trackers_all.txt.tmp trackers_all.txt
      fi
    '';
  };

  systemd.timers.trackerslist-update = {
    partOf = [ "transmission.service" ];
    wantedBy = [ "transmission.service" ];
    timerConfig = {
      OnCalendar = "daily";
    };
  };

  systemd.services.transmission-load-default-trackers = {
    after = [ "transmission.service" ];
    partOf = [ "transmission.service" ];
    wantedBy = [ "transmission.service" ];
    enableStrictShellChecks = true;
    serviceConfig = {
      Type = "oneshot";
      User = config.services.transmission.user;
      Group = config.services.transmission.group;

      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = [ transmissionSettingsDir ];
      ReadOnlyPaths = [ "/var/cache/trackerslist" ];
      UMask = "0077";

      AmbientCapabilities = "";
      CapabilityBoundingSet = "";
      DevicePolicy = "closed";
      PrivateNetwork = true;
      NoNewPrivileges = true;
      ProtectKernelTunables = true;
      ProtectControlGroups = true;
      PrivateDevices = true;
      ProtectClock = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      RemoveIPC = true;
      RestrictAddressFamilies = [ "AF_UNIX" ];
      SystemCallArchitectures = "native";
      SystemCallFilter = [ "@system-service" ];
      MemoryDenyWriteExecute = true;
      RestrictNamespaces = true;
      RestrictSUIDSGID = true;
      ProtectHostname = true;
      LockPersonality = true;
      RestrictRealtime = true;
      ProtectProc = "invisible";
      ProcSubset = "pid";
      PrivateTmp = true;
      ExecStartPost = "!${config.systemd.package}/bin/systemctl reload transmission.service";
    };
    path = [
      pkgs.jq
    ];
    script = ''
      settings="${transmissionSettingsDir}/settings.json"

      jq --rawfile trackers /var/cache/trackerslist/trackers_all.txt \
        '."default-trackers" = $trackers' "$settings" >"$settings.tmp"
      mv "$settings.tmp" "$settings"
    '';
  };
}
