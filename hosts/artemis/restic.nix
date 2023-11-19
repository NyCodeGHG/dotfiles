{ config, pkgs, inputs, ... }:
let
  repository = "s3:s3.eu-central-003.backblazeb2.com/marie-backups";
  mkResticService = service: {
    serviceConfig = {
      User = "root";
      Type = "oneshot";
    };
    environment = {
      RESTIC_REPOSITORY = repository;
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

  systemd.services."restic-backup-forgejo" = mkResticService {
    serviceConfig = {
      EnvironmentFile = config.age.secrets.b2-restic.path;
    };
    environment = {
      GITEA_WORK_DIR = config.services.forgejo.stateDir;
      GITEA_CUSTOM = config.services.forgejo.customDir;
      RESTIC_REPOSITORY = repository;
      RESTIC_PASSWORD_FILE = config.age.secrets.restic-repo.path;
      XDG_CACHE_DIR = "/var/cache/";
    };
    script = ''
      set -eo pipefail
      HOME="${config.services.forgejo.stateDir}" ${pkgs.sudo}/bin/sudo -Eu forgejo ${config.services.forgejo.package}/bin/gitea dump --type tar -f - | \
      ${pkgs.restic}/bin/restic backup \
        --tag forgejo \
        --stdin \
        --stdin-filename forgejo-dump-$(${pkgs.coreutils}/bin/date +%Y-%m-%d_%H-%M-%S).tar

      ${pkgs.restic}/bin/restic forget \
        --tag forgejo \
        --host ${config.networking.hostName} \
        --keep-daily 7 \
        --keep-weekly 5 \
        --keep-monthly 12 \
        --keep-yearly 75
    '';
  };

  services.restic.backups.matrix-synapse = {
    repository = "s3:s3.eu-central-003.backblazeb2.com/marie-backups";
    environmentFile = config.age.secrets.b2-restic.path;
    pruneOpts = [
      "--keep-daily 2"
      "--keep-weekly 1"
      "--keep-monthly 2"
      "--tag matrix-synapse"
      "--host ${config.networking.hostName}"
    ];
    timerConfig = {
      OnCalendar = "0/6:00"; # every 6 hours
      Persistent = true;
    };
    extraBackupArgs = [
      "--tag matrix-synapse"
    ];
    paths = [
      "/var/lib/matrix-synapse"
    ];
    passwordFile = config.age.secrets.restic-repo.path;
  };
}
