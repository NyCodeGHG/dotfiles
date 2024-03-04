{ config, pkgs, inputs, lib, ... }:
let
  repository = "s3:s3.eu-central-003.backblazeb2.com/marie-backups";
  mkResticService = service: {
    serviceConfig = {
      EnvironmentFile = config.age.secrets.b2-restic.path;
    };
    environment = {
      RESTIC_REPOSITORY = repository;
      RESTIC_PASSWORD_FILE = config.age.secrets.restic-repo.path;
      XDG_CACHE_DIR = "/var/cache/";
    };
  } // service;
  restic-wrapper = pkgs.writeShellScriptBin "restic-wrapped" ''
    set -aeuo pipefail
    source ${config.age.secrets.b2-restic.path}
    RESTIC_REPOSITORY=${repository}
    RESTIC_PASSWORD_FILE=${config.age.secrets.restic-repo.path}
    exec ${pkgs.restic}/bin/restic $@
  '';
in
{
  users.users.root.packages = [ restic-wrapper ];
  age.secrets.restic-repo.file = "${inputs.self}/secrets/restic-repo.age";
  age.secrets.b2-restic.file = "${inputs.self}/secrets/b2-restic.age";

  systemd.timers."restic-backup-postgres" = {
    wantedBy = [ "timers.target" ];
    partOf = [ "restic-backup-postgres.service" ];
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "1200";
    };
  };

  systemd.timers."restic-backup-forgejo" = {
    wantedBy = [ "timers.target" ];
    partOf = [ "restic-backup-forgejo.service" ];
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "1200";
    };
  };

  systemd.services."restic-backup-postgres" = mkResticService {
    path = with pkgs; [ sudo restic config.services.postgresql.package ];
    script = ''
      set -euo pipefail
      
      sudo -u postgres pg_dumpall | \
      restic backup \
        --retry-lock 30m \
        --tag postgres \
        --stdin \
        --stdin-filename 'all_databases.psql'

      restic forget \
        --retry-lock 30m \
        --tag postgres \
        --host ${config.networking.hostName} \
        --keep-daily 7 \
        --keep-weekly 5 \
        --keep-monthly 12 \
        --keep-yearly 75
    '';
  };

  systemd.services."restic-backup-forgejo" = mkResticService {
    environment = {
      GITEA_WORK_DIR = config.services.forgejo.stateDir;
      GITEA_CUSTOM = config.services.forgejo.customDir;
      RESTIC_REPOSITORY = repository;
      RESTIC_PASSWORD_FILE = config.age.secrets.restic-repo.path;
      XDG_CACHE_DIR = "/var/cache/";
    };
    path = with pkgs; [ sudo coreutils config.services.forgejo.package restic ];
    script = ''
      set -euo pipefail
      HOME="${config.services.forgejo.stateDir}" sudo -Eu forgejo gitea dump --type tar -f - | \
      restic backup \
        --retry-lock 30m \
        --tag forgejo \
        --stdin \
        --stdin-filename forgejo-dump-$(date +%Y-%m-%d_%H-%M-%S).tar

      restic forget \
        --retry-lock 30m \
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
      "--retry-lock 30m"
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
      "--retry-lock 30m"
      "--tag matrix-synapse"
    ];
    paths = [
      "/var/lib/matrix-synapse"
    ];
    passwordFile = config.age.secrets.restic-repo.path;
  };

  services.restic.backups.paperless = {
    repository = "s3:s3.eu-central-003.backblazeb2.com/marie-backups";
    environmentFile = config.age.secrets.b2-restic.path;
    pruneOpts = [
      "--retry-lock 30m"
      "--keep-daily 1"
      "--keep-weekly 2"
      "--keep-monthly 2"
      "--tag paperless"
      "--host ${config.networking.hostName}"
    ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "3h";
    };
    extraBackupArgs = [
      "--retry-lock 30m"
      "--tag paperless"
    ];
    paths = [
      "/var/lib/paperless"
    ];
    passwordFile = config.age.secrets.restic-repo.path;
  };

  services.restic.backups.grafana = {
    repository = "s3:s3.eu-central-003.backblazeb2.com/marie-backups";
    environmentFile = config.age.secrets.b2-restic.path;
    pruneOpts = [
      "--retry-lock 30m"
      "--keep-daily 1"
      "--keep-weekly 2"
      "--keep-monthly 2"
      "--tag grafana"
      "--host ${config.networking.hostName}"
    ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "3h";
    };
    extraBackupArgs = [
      "--retry-lock 30m"
      "--tag grafana"
    ];
    paths = [
      "/var/lib/grafana"
    ];
    passwordFile = config.age.secrets.restic-repo.path;
  };
}
