{
  lib,
  config,
  options,
  utils,
  ...
}:
{
  options.uwumarie.harmonia-tailscale = {
    enable = lib.mkEnableOption "harmonia tailscale";
    inherit (options.services.harmonia.cache) signKeyPaths;
  };
  config = lib.mkIf config.uwumarie.harmonia-tailscale.enable {
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "tailscale must be enabled";
      }
    ];

    services.harmonia.cache = {
      enable = true;
      inherit (config.uwumarie.harmonia-tailscale) signKeyPaths;
      settings = {
        bind = "/run/harmonia/socket";
        priority = 30;
      };
    };

    systemd.services.tailscale-serve-harmonia = {
      after = [
        "harmonia.socket"
        "tailscaled.service"
        "tailscale-online.target"
      ];
      wants = [
        "harmonia.socket"
        "tailscaled.service"
        "tailscale-online.target"
      ];
      wantedBy = [ "multi-user.target" ];
      confinement = {
        enable = true;
        binSh = null;
      };
      serviceConfig = {
        ExecStart = utils.escapeSystemdExecArgs [
          (lib.getExe config.services.tailscale.package)
          "--socket=/run/tailscale/tailscaled.sock"
          "serve"
          "--https=7777"
          "unix:/run/harmonia/socket"
        ];

        BindReadOnlyPaths = [
          "/run/harmonia/socket"
          "/run/tailscale/tailscaled.sock"
        ];
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectHostname = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";
        PrivateTmp = false;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateIPC = true;
        PrivateNetwork = true;
        InaccessiblePaths = [ "+/dev/shm" ];
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = "strict";
        LockPersonality = true;
        NoNewPrivileges = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        ProtectClock = true;
        MemoryDenyWriteExecute = true;
        UMask = "0077";
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
          "~memfd_create"
        ];
        RestrictAddressFamilies = [ "AF_UNIX" ];
        CapabilityBoundingSet = "";
      };
    };
  };
}
