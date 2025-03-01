{ config, inputs, pkgs, ... }:
let
  frontendPackage = inputs.ip-playground.packages.${pkgs.system}.ip-playground-frontend;
  backendPackage = inputs.ip-playground.packages.${pkgs.system}.ip-playground-backend;
  asnDbPath = "/var/lib/ip-playground/ip2asn-combined.tsv";
in
{
  services.nginx.virtualHosts = {
    "ip.marie.cologne" = {
      locations."/" = {
        root = "${frontendPackage}";
        index = "index.html";
        extraConfig = ''
          if ($http_user_agent ~* "^curl\/.+") {
            rewrite ^ /api/info last;
          }
        '';
      };
      locations."/api" = {
        proxyPass = "http://127.0.0.1:3032";
      };
      serverAliases = [
        "v4.ip.marie.cologne"
        "v6.ip.marie.cologne"
      ];
      useACMEHost = "ip.marie.cologne";
    };
  };
  security.acme.certs."ip.marie.cologne" = {
    domain = "ip.marie.cologne";
    extraDomainNames = [
      "*.ip.marie.cologne"
    ];
  };
  services.redis.servers.ip-playground = {
    enable = true;
    user = "ip-playground";
  };
  systemd.timers.download-iptoasn-db = {
    wantedBy = [ "timers.target" ];
    partOf = [ "download-iptoasn-db.service" ];
    timerConfig = {
      OnCalendar = "00/3:00:00";
      RandomizedDelaySec = "30m";
      Persistent = true;
    };
  };
  systemd.services = {
    download-iptoasn-db = {
      description = "IP to ASN Database download";
      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];
      serviceConfig = {
        WorkingDirectory = "/var/lib/ip-playground";
        # ExecStartPost = "+${pkgs.systemd}/bin/systemctl reload ip-playground.service";
        Type = "oneshot";
        Restart = "on-failure";
        RestartSec = "10";
        LockPersonality = true;
        NoNewPrivileges = true;
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
        ProtectSystem = "full";
        RemoveIPC = true;
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        User = "ip-playground";
        Group = "ip-playground";
      };
      path = with pkgs; [ curl gzip ];
      script = ''
        set -eo pipefail
        curl -fsSL \
              --verbose \
             --etag-save /var/lib/ip-playground/etag.txt \
             --etag-compare /var/lib/ip-playground/etag.txt \
             -O \
             "https://iptoasn.com/data/ip2asn-combined.tsv.gz"
        if [ -f /var/lib/ip-playground/ip2asn-combined.tsv.gz ]; then
          gzip -df /var/lib/ip-playground/ip2asn-combined.tsv.gz
        fi

        if systemctl is-active --quiet ip-playground.service; then
          curl -X POST --fail --verbose "http://127.0.0.1:3032/reload"
        fi
      '';
    };
    ip-playground = {
      description = "IP Playground";
      wants = [ "network.target" "download-iptoasn-db.service" ];
      after = [ "network.target" "download-iptoasn-db.service" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        ALLOWED_ORIGINS = "https://ip.marie.cologne,https://v4.ip.marie.cologne,https://v6.ip.marie.cologne";
        PORT = "3032";
        LOG_FORMAT = "json";
        ASN_DB_PATH = asnDbPath;
        REDIS_URL = "redis+unix://${config.services.redis.servers.ip-playground.unixSocket}";
        RUST_LOG = "info";
      };
      serviceConfig = {
        ExecStart = "${backendPackage}/bin/ip-playground";
        Restart = "always";
        CapabilityBoundingSet = [ "" ];
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
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
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [ "@system-service" "~@resources" "~@privileged" ];
        User = "ip-playground";
        Group = "ip-playground";
      };
    };
  };
  users.users.ip-playground = {
    home = "/var/lib/ip-playground";
    createHome = true;
    isSystemUser = true;
    group = "ip-playground";
  };
  users.groups.ip-playground = { };
}
