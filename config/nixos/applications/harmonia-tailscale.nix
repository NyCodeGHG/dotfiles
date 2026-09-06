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
      ];
      wants = [
        "harmonia.socket"
        "tailscaled.service"
      ];
      wantedBy = [ "multi-user.target" ];
      confinement.enable = true;
      serviceConfig = {
        ExecStart = utils.escapeSystemdExecArgs [
          (lib.getExe config.services.tailscale.package)
          "--socket=/run/tailscale/tailscaled.sock"
          "serve"
          "--https=7777"
          "unix:/run/harmonia/socket"
        ];

        BindPaths = [
          "/run/harmonia/socket"
          "/run/tailscale/tailscaled.sock"
        ];
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectHostname = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";
        PrivateTmp = "disconnected";
        PrivateDevices = true;
        PrivateMounts = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        LockPersonality = true;
        NoNewPrivileges = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        ProtectClock = true;
        MemoryDenyWriteExecute = true;
        UMask = "0077";
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "~@clock"
          "~@cpu-emulation"
          "~@debug"
          "~@module"
          "~@mount"
          "~@obsolete"
          "~@privileged"
          "~@raw-io"
          "~@reboot"
          "~@resources"
          "~@swap"
        ];
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        SocketBindAllow = "7777";
        SocketBindDeny = "any";
        RestrictNetworkInterfaces = [ "tailscale0" ];
        CapabilityBoundingSet = [ "@system-service" ];
      };
    };
  };
}
