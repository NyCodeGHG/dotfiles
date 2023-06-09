{ config, pkgs, lib, inputs, ... }:
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
    onFailure = [ "restic-backup-postgres-notification@%n.service" ];
    onSuccess = [ "restic-backup-postgres-notification-success.service" ];
  };

  systemd.services."restic-backup-postgres-notification@" =
    let
      script = pkgs.writeScript "notification" ''
        UNIT=$1
        HOST=$2

        UNITSTATUS=$(systemctl status $UNIT)

        ${pkgs.discord-sh}/bin/discord.sh \
          --username "Restic Backup" \
          --avatar "https://restic.readthedocs.io/en/stable/_static/logo.png" \
          --text "<@449893028266770432>" \
          --title ":x: Backup Failed!" \
          --color "0xFF0000" \
          --timestamp \
          --field "Unit;$UNIT" \
          --description "$(echo $UNITSTATUS | ${pkgs.jq}/bin/jq -Rs . | cut -c 2- | ${pkgs.util-linux}/bin/rev | cut -c 2- | ${pkgs.util-linux}/bin/rev)"
      '';
    in
    {
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash ${script} %I %H";
        EnvironmentFile = config.age.secrets.discord-webhook.path;
      };
      unitConfig = {
        Description = "Restic Backup Postgres Notification";
        After = "network.target";
      };
    };

  systemd.services."restic-backup-postgres-notification-success" = mkResticService
    {
      serviceConfig = {
        EnvironmentFile = [ config.age.secrets.b2-restic.path config.age.secrets.discord-webhook.path ];
      };
      unitConfig = {
        Description = "Restic Backup Success Postgres Notification";
        After = "network.target";
      };
      script =
        let
          numfmt = value: ''numfmt --to=iec-i --suffix=B --format="%9.2f" ${value}'';
        in
        ''
          set -eo pipefail

          STATS=$(${pkgs.restic}/bin/restic stats \
            --tag postgres \
            --host ${config.networking.hostName} \
            --mode raw-data \
            --json)

          TOTAL_SIZE=$(echo $STATS | ${pkgs.jq}/bin/jq ".total_size")
          TOTAL_UNCOMPRESSED_SIZE=$(echo $STATS | ${pkgs.jq}/bin/jq ".total_uncompressed_size")
          COMPRESSION_RATIO=$(echo $STATS | ${pkgs.jq}/bin/jq ".compression_ratio")
          COMPRESSION_SPACE_SAVING=$(echo $STATS | ${pkgs.jq}/bin/jq ".compression_space_saving")
          TOTAL_BLOB_COUNT=$(echo $STATS | ${pkgs.jq}/bin/jq ".total_blob_count")
          SNAPSHOTS_COUNT=$(echo $STATS | ${pkgs.jq}/bin/jq ".snapshots_count")

          export LC_NUMERIC="en_US.UTF-8"
          ${pkgs.discord-sh}/bin/discord.sh \
            --username "Restic Backup" \
            --avatar "https://restic.readthedocs.io/en/stable/_static/logo.png" \
            --title ":white_check_mark: Backup created!" \
            --color "0x00FF00" \
            --timestamp \
            --field "Total Size;$(${numfmt "$TOTAL_SIZE"})" \
            --field "Total Uncompressed Size;$(${numfmt "$TOTAL_UNCOMPRESSED_SIZE"})" \
            --field "Compression Ratio;$(printf "%8.2f" "$COMPRESSION_RATIO")" \
            --field "Compression Space Saving;$(printf "%8.2f" "$COMPRESSION_SPACE_SAVING")%" \
            --field "Total Blobs;$TOTAL_BLOB_COUNT" \
            --field "Snapshots;$SNAPSHOTS_COUNT" \
            --description "$(${pkgs.restic}/bin/restic version)"
        '';
    };
  age.secrets.discord-webhook.file = ../../secrets/discord-webhook.age;
}
