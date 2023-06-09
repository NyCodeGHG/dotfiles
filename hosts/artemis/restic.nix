{ config, pkgs, lib, inputs, ... }:
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

  systemd.services."restic-backup-postgres" = {
    serviceConfig = {
      User = "root";
      Type = "oneshot";
      EnvironmentFile = config.age.secrets.b2-restic.path;
    };
    environment = {
      RESTIC_REPOSITORY = "s3:s3.eu-central-003.backblazeb2.com/marie-backups";
      RESTIC_PASSWORD_FILE = config.age.secrets.restic-repo.path;
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
          --color "0x00FFFF" \
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

  age.secrets.discord-webhook.file = ../../secrets/discord-webhook.age;
}
