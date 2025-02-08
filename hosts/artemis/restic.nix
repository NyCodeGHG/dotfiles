{ config, pkgs, lib, ... }:
let
  mkResticService = service: lib.recursiveUpdate {
    serviceConfig = {
      EnvironmentFile = config.age.secrets.restic.path;
      User = "backup";
      Group = "backup";
      PrivateTmp = true;
    };
  } service;
  resticWrapper = pkgs.writeScriptBin "restic-wrapper"
    ''
      set -aeuo pipefail
      source ${config.age.secrets.restic.path}
      exec ${lib.getExe pkgs.restic} "$@"
    '';
in
{
  environment.systemPackages = [ resticWrapper ];
  age.secrets.restic.file = ./secrets/restic.age;
  users.users.backup = {
    isSystemUser = true;
    group = "backup";
  };
  users.groups.backup = {};

  systemd.services."postgres-user-backup" = {
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      Group = "postgres";
      ExecStart = "${lib.getExe' config.services.postgresql.package "psql"} -c 'CREATE ROLE backup WITH LOGIN IN ROLE pg_read_all_data;'";
      ExecStop = "${lib.getExe' config.services.postgresql.package "psql"} -c 'DROP ROLE backup;'";
      RemainAfterExit = true;
    };
    unitConfig = {
      StopWhenUnneeded = true;
    };
  };

  systemd.services."restic-postgres" = mkResticService {
    requires = [ "postgres-user-backup.service" ];
    after = [ "postgres-user-backup.service" ];
    path = with pkgs; [ restic config.services.postgresql.package gnugrep gawk hostname-debian ];
    startAt = "03:00";
    script = ''
      set -euo pipefail
      dir="$(mktemp -d /tmp/postgres-backup.XXXXXX)"

      for db in $(psql postgres -tc 'SELECT datname FROM pg_database WHERE datistemplate = false;' | grep '\S' | awk '{$1=$1};1'); do
        echo "Dumping schema for database $db"
        pg_dump "$db" \
          --schema-only \
          --file "$dir/$db-schema.psql"

        echo "Dumping data for database $db"
        pg_dump "$db" \
          --data-only \
          --file "$dir/$db-data.psql"
      done

      echo "Backing up using restic"

      env -C "$dir" restic backup \
        --retry-lock 30m \
        --one-file-system \
        --tag postgres \
        --skip-if-unchanged \
        .

      echo "Cleaning up old snapshots"

      restic forget \
        --retry-lock 30m \
        --tag postgres \
        --host "$(hostname)" \
        --keep-within 7d \
        --keep-weekly 4 \
        --keep-monthly 12 \
        --keep-yearly 5
    '';
  };

  systemd.services."restic-forgejo" = mkResticService {
    environment = 
    let
      cfg = config.services.forgejo;
    in {
      USER = cfg.user;
      HOME = cfg.stateDir;
      FORGEJO_WORK_DIR = cfg.stateDir;
      FORGEJO_CUSTOM = cfg.customDir;
    };
    path = with pkgs; [ config.services.forgejo.package restic hostname-debian ];
    serviceConfig = {
      User = "forgejo";
      Group = "forgejo";
    };
    startAt = "03:00";
    script = ''
      set -euo pipefail
      ${lib.getExe config.services.forgejo.package} dump --type tar -f - | \
        restic backup \
          --retry-lock 30m \
          --tag forgejo \
          --stdin \
          --stdin-filename forgejo-dump.tar

      restic forget \
        --retry-lock 30m \
        --tag forgejo \
        --host "$(hostname)" \
        --keep-within 7d \
        --keep-weekly 4 \
        --keep-monthly 12 \
        --keep-yearly 5
    '';
  };
  systemd.services."restic-paperless" = mkResticService {
    path = with pkgs; [ restic hostname-debian ];
    serviceConfig = {
      User = "paperless";
      Group = "paperless";
    };
    startAt = "03:00";
    script = ''
      set -euo pipefail
      restic backup \
        --retry-lock 30m \
        --tag paperless \
        /var/lib/paperless

      restic forget \
        --retry-lock 30m \
        --tag paperless \
        --host "$(hostname)" \
        --keep-within 7d \
        --keep-weekly 4 \
        --keep-monthly 12 \
        --keep-yearly 5
    '';
  };
  systemd.services."restic-synapse" = mkResticService {
    path = with pkgs; [ restic hostname-debian ];
    serviceConfig = {
      User = "matrix-synapse";
      Group = "matrix-synapse";
    };
    startAt = "03:00";
    script = ''
      set -euo pipefail
      restic backup \
        --retry-lock 30m \
        --tag synapse \
        /var/lib/matrix-synapse

      restic forget \
        --retry-lock 30m \
        --tag synapse \
        --host "$(hostname)" \
        --keep-within 7d \
        --keep-weekly 4 \
        --keep-monthly 12 \
        --keep-yearly 5
    '';
  };
}
