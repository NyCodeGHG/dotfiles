{ config, pkgs, lib, utils, ... }:
let
  cfg = config.services.pgrok;
  yaml = pkgs.formats.yaml { };
in
{
  options.services.pgrok = with lib; {
    enable = mkEnableOption "pgrok";
    settings = mkOption {
      type = yaml.type;
      description = lib.mdDoc ''
        Configuration for pgrok.
      '';
    };
    statePath = mkOption {
      type = types.str;
      description = lib.mdDoc ''
        State Directory for pgrok.
      '';
      default = "/var/lib/pgrok";
    };
    user = mkOption {
      type = types.str;
      default = "pgrok";
      description = lib.mdDoc "User to run pgrok";
    };
    group = mkOption {
      type = types.str;
      default = "pgrok";
      description = lib.mdDoc "Group to run pgrok";
    };
  };
  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      home = cfg.statePath;
      group = cfg.group;
      createHome = true;
    };
    users.groups.${cfg.group} = { };

    systemd.targets.pgrok = {
      description = "Common Target for pgrok";
      wantedBy = [ "multi-user.target" ];
    };

    systemd.services =
      let
        configPath = "${cfg.statePath}/config.yml";
      in
      {
        pgrok-config = {
          wantedBy = [ "pgrok.target" ];
          partOf = [ "pgrok.target" ];
          path = with pkgs; [
            jq
            replace-secret
          ];
          serviceConfig = {
            Type = "oneshot";
            User = cfg.user;
            Group = cfg.group;
            TimeoutSec = "infinity";
            Restart = "on-failure";
            WorkingDirectory = cfg.statePath;
            RemainAfterExit = true;
            ExecStart = pkgs.writeShellScript "pgrok-config" ''
              umask u=rwx,g=,o=
              ${utils.genJqSecretsReplacementSnippet
                cfg.settings configPath
              }
            '';
          };
        };
        pgrok = {
          after = [
            "network.target"
            "pgrok-config.service"
          ];
          bindsTo = [
            "pgrok-config.service"
          ];
          wantedBy = [ "pgrok.target" ];
          partOf = [ "pgrok.target" ];
          serviceConfig = {
            Type = "simple";
            User = cfg.user;
            Group = cfg.group;
            TimeoutSec = "infinity";
            Restart = "always";
            WorkingDirectory = cfg.statePath;
            ExecStart = "${pkgs.pgrok.server}/bin/pgrokd --config ${configPath}";
          };
        };
      };
  };
}
