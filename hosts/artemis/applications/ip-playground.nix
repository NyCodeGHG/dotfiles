{ inputs, pkgs, ...}:
let
  frontendPackage = inputs.ip-playground.packages.${pkgs.system}.ip-playground-frontend;
  backendPackage= inputs.ip-playground.packages.${pkgs.system}.ip-playground-backend;
in
{
  uwumarie.reverse-proxy.services = {
    "ip.marie.cologne" = {
      locations."/" = {
        root = "${frontendPackage}";
        index = "index.html";
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
  systemd.services.ip-playground = {
    description = "IP Playground";
    after = ["network.target"];
    wantedBy = [ "multi-user.target" ];
    environment = {
      ALLOWED_ORIGINS = "https://ip.marie.cologne,https://v4.ip.marie.cologne,https://v6.ip.marie.cologne";
      PORT = "3032";
    };
    serviceConfig = {
      ExecStart = ''
        ${backendPackage}/bin/ip-playground
      '';
      Restart = "on-failure";
      CapabilityBoundingSet = [ "" ];
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
      ProtectSystem = "strict";
      ReadWritePaths = [];
      RemoveIPC = true;
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [ "@system-service" "~@resources" "~@privileged" ];
      DynamicUser = "yes";
    };
  };
}