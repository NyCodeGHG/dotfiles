{
  config,
  inputs,
  pkgs,
  ...
}:
let
  package = inputs.ip-playground.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  services.nginx.virtualHosts = {
    "ip.marie.cologne" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:3032";
        extraConfig = ''
          if ($http_user_agent ~* "^curl\/.+") {
            rewrite ^ /api/info last;
          }
        '';
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
  systemd.services = {
    ip-playground = {
      description = "IP Playground";
      wants = [ "network.target" ];
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        DEFAULT_PAGE = "https://ip.marie.cologne";
        V4_PAGE = "https://v4.ip.marie.cologne";
        V6_PAGE = "https://v6.ip.marie.cologne";
        PORT = "3032";
        LOG_FORMAT = "json";
        REDIS_URL = "redis+unix://${config.services.redis.servers.ip-playground.unixSocket}";
        RUST_LOG = "info";
        IPLOOKUPD_URL = "http://localhost:7805";
        IP_BACKEND = "iplookupd";
        USER_AGENT = "ip-playground +https://chaos.social/@marie";
      };
      serviceConfig = {
        ExecStart = "${package}/bin/ip-playground";
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
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "~@resources"
          "~@privileged"
        ];
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
