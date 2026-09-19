{
  pkgs,
  lib,
  config,
  options,
  ...
}:
let
  cfg = config.uwumarie.agenix;
in
{
  options.uwumarie.agenix = {
    enable = lib.mkEnableOption "agenix host key generation";
    provisioning = {
      enable = lib.mkEnableOption "agenix host key provisioning";
      credential = lib.mkOption {
        description = "The systemd credential to use for provisioning.";
        default = "agenix.host_key";
        type = lib.types.nonEmptyStr;
      };
    };
  };
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf cfg.provisioning.enable {
        assertions = [
          {
            assertion = config.services.userborn.enable;
            message = "services.userborn.enable must be enabled for provisioning to work.";
          }
        ];

        systemd.tmpfiles.settings."10-agenix-provision" = lib.mkIf cfg.provisioning.enable {
          "/var/lib/agenix/host_key.txt"."f^" = {
            user = "root";
            group = "root";
            mode = "0600";
            argument = cfg.provisioning.credential;
          };
        };

        systemd.services = {
          systemd-tmpfiles-setup = {
            enableDefaultPath = false;
            serviceConfig.ImportCredential = [ cfg.provisioning.credential ];
          };
          systemd-tmpfiles-resetup = {
            enableDefaultPath = false;
            serviceConfig.ImportCredential = [ cfg.provisioning.credential ];
          };
          agenix-install-secrets = {
            after = [ "systemd-tmpfiles-setup.service" ];
            before = [ "sysinit.target" ];
          };
        };
      })
      (
        lib.optionalAttrs (options ? age) {
          age.identityPaths = [
            "/var/lib/agenix/host_key.txt"
          ]
          ++ lib.optionals config.services.openssh.enable (
            lib.pipe config.services.openssh.hostKeys [
              (lib.filter (e: e.type == "rsa" || e.type == "ed25519"))
              (map (e: e.path))
            ]
          );
        }
        // {
          systemd.services.agenix-keygen = {
            description = "Generate agenix host key";
            wantedBy = [ "sysinit.target" ];
            before = [ "agenix-install-secrets.service" ];
            unitConfig = {
              ConditionPathExists = "!%S/agenix/host_key.txt";
              ConditionCredential = "!agenix.host_key";
              DefaultDependencies = false;
            };
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${lib.getExe' pkgs.age "age-keygen"} -pq -o %S/agenix/host_key.txt";
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
              RestrictAddressFamilies = "";
              ProtectClock = true;
              ProtectControlGroups = true;
              ProtectHostname = true;
              ProtectKernelLogs = true;
              ProtectKernelModules = true;
              ProtectKernelTunables = true;
              SystemCallArchitectures = "native";
              SystemCallFilter = "@system-service";
              SocketBindDeny = "any";
            };
          };
        }
      )
    ]
  );
}
