{ config, pkgs, lib, ... }:
let
  inherit (lib) mkOption mkEnableOption types mkPackageOption;
  cfg = config.services.scanservjs;
  stateDir = "/var/lib/scanservjs";
  scanservjs = cfg.package.override {
    tesseract = pkgs.tesseract.override {
      enableLanguages = [ "deu" "eng" ];
    };
  };
in
{
  options.services.scanservjs = {
    enable = mkEnableOption "scanservjs";
    package = mkPackageOption pkgs "scanservjs" { };
  };

  config = {
    systemd.services.scanservjs-data-setup = {
      description = "scanservjs: data setup";
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ bash rsync ];

      serviceConfig = {
        Type = "oneshot";
        User = "scanservjs";
        Group = "scanservjs";
        StateDirectory = "scanservjs";
        WorkingDirectory = stateDir;

        CapabilityBoundingSet = "";
        DynamicUser = true;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateMounts = true;
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
        RestrictAddressFamilies = "none";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = "077";
      };
      script = ''
        mkdir -p /var/lib/scanservjs/config
        rsync -av --no-perms ${scanservjs}/config-static/ /var/lib/scanservjs/config
        mkdir -p /var/lib/scanservjs/data
        rsync -av --no-perms ${scanservjs}/data-static/ /var/lib/scanservjs/data
      '';
    };

    systemd.services.scanservjs =
      {
        description = "scanservjs";
        wantedBy = [ "multi-user.target" ];
        after = [ "scanservjs-data-setup.service" "network.target" ];
        requires = [ "scanservjs-data-setup.service" "network.target" ];

        serviceConfig = {
          ExecStart = "${scanservjs}/bin/scanservjs";
          User = "scanservjs";
          Group = "scanservjs";
          StateDirectory = "scanservjs";
          WorkingDirectory = stateDir;

          CapabilityBoundingSet = "";
          DynamicUser = true;
          LockPersonality = true;
          NoNewPrivileges = true;
          PrivateMounts = true;
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
          RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SupplementaryGroups = [ "scanner" ];
          SystemCallArchitectures = "native";
          UMask = "077";
        };
        environment = {
          # Required for sane to use the system config
          LD_LIBRARY_PATH = "/etc/sane-libs";
          SANE_CONFIG_DIR = "/etc/sane-config";

          NODE_ENV = "production";
          # Required for version in about page, which executes npm. npm crashes if it can't find a home dir.
          HOME = stateDir;
        };
      };
  };
}
