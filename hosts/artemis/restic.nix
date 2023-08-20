{ config, pkgs, inputs, ... }:
let
  mkResticService = service: {
    serviceConfig = {
      User = "root";
      Type = "oneshot";
    };
    environment = {
      RESTIC_REPOSITORY = "s3:s3.eu-central-003.backblazeb2.com/marie-backups";
      RESTIC_PASSWORD_FILE = config.age.secrets.restic-repo.path;
      XDG_CACHE_DIR = "/var/cache/";
    };
  } // service;
in
{
  age.secrets.restic-repo.file = "${inputs.self}/secrets/restic-repo.age";
  age.secrets.b2-restic.file = "${inputs.self}/secrets/b2-restic.age";

  systemd.timers."restic-backup-postgres" = {
    wantedBy = [ "timers.target" ];
    partOf = [ "restic-backup-postgres.service" ];
    timerConfig = {
      OnCalendar = "daily";
    };
  };

  systemd.services."restic-backup-postgres" = mkResticService {
    serviceConfig = {
      EnvironmentFile = config.age.secrets.b2-restic.path;
    };
    script = ''
      set -eo pipefail
      ${pkgs.sudo}/bin/sudo -u postgres ${config.services.postgresql.package}/bin/pg_dumpall | \
      ${pkgs.restic}/bin/restic backup \
        --tag postgres \
        --stdin \
        --stdin-filename all_databases.sql

      ${pkgs.restic}/bin/restic forget \
        --tag postgres \
        --host ${config.networking.hostName} \
        --keep-daily 7 \
        --keep-weekly 5 \
        --keep-monthly 12 \
        --keep-yearly 75
    '';
  };
}
