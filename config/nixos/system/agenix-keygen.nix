{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.uwumarie.agenix.enable = lib.mkEnableOption "agenix host key generation";
  config = lib.mkIf config.uwumarie.agenix.enable {
    systemd.services.agenix-keygen = {
      description = "Generate agenix host key";
      wantedBy = [ "multi-user.target" ];
      unitConfig = {
        ConditionFileNotEmpty = "!%S/agenix/host_key.txt";
      };
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe' pkgs.age "age-keygen"} -pq -o %S/agenix/host_key.txt";
        WorkingDirectory = "%S/agenix";
        StateDirectory = "agenix";

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateNetwork = true;
        PrivateTmp = true;
        PrivateUsers = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectProc = "invisible";
        RestrictAddressFamilies = [ ];
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
        SocketBindDeny = "deny";
      };
    };
  };
}
