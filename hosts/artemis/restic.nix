{ config, pkgs, lib, inputs, ... }:
{
  # services.restic.backups.gdrive = {
  #   initialize = true;
  #   passwordFile = config.age.secrets.restic-repo.path;
  #   paths = [ ];
  #   pruneOpts = [
  #     "--keep-last 5"
  #     "--keep-weekly 5"
  #     "--keep-monthly 12"
  #     "--keep-yearly 75"
  #   ];
  # };
  age.secrets.restic-repo.file = "${inputs.self}/secrets/restic-repo.age";
  age.secrets.rclone-config.file = "${inputs.self}/secrets/rclone-config.age";

  systemd.timers."restic-backup-postgres" = {
    wantedBy = [ "timers.target" ];
    partOf = [ "restic-backup-postgres.service" ];
    timerConfig = {
      OnCalendar = "daily";
    };
  };

  systemd.services."restic-backup-postgres" = {
    serviceConfig = {
      User = "root";
      Type = "oneshot";
    };
    environment = {
      RESTIC_REPOSITORY = "rclone:gdrive:Backups/${config.networking.hostName}";
      RESTIC_PASSWORD_FILE = config.age.secrets.restic-repo.path;
      RCLONE_CONFIG = config.age.secrets.rclone-config.path;
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
